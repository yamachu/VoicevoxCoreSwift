#!/usr/bin/env python3
"""上流の voicevox_core.h と Swift 側の定義が同期しているかを検査する。

このリポジトリはヘッダと型定義のみを提供するため、テストバイナリをリンクできない。
そのため実行時テストの代わりに、リポジトリに取り込んだヘッダをパースして
Swift 側の enum / API ラッパーと突き合わせる。

使い方:
    python3 Scripts/check_header_sync.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAC_HEADER = ROOT / "Sources/VoicevoxCoreSwiftMAC/include/voicevox_core.h"
IOS_HEADER = ROOT / "Sources/VoicevoxCoreSwiftIOS/include/voicevox_core.h"
SWIFT_DIR = ROOT / "Sources/VoicevoxCoreSwift"
UNWRAPPED_APIS = ROOT / "Scripts/unwrapped_apis.txt"

LINK = "VOICEVOX_LINK_ONNXRUNTIME"
LOAD = "VOICEVOX_LOAD_ONNXRUNTIME"

# 検査対象の enum 。
#   c_name:     ヘッダ側の enum 名
#   swift_file: Swift 側の定義ファイル (Sources/VoicevoxCoreSwift からの相対)
#   swift_name: Swift 側の enum 名
#   prefix:     C 側の case 名に付く接頭辞
#   style:      C の SNAKE_CASE から Swift の case 名への変換規則
ENUMS = [
    {
        "c_name": "VoicevoxResultCode",
        "swift_file": "Enum/ResultCode.swift",
        "swift_name": "ResultCode",
        "prefix": "VOICEVOX_RESULT_",
        "style": "upper_snake",
    },
    {
        "c_name": "VoicevoxAccelerationMode",
        "swift_file": "Enum/AccelerationMode.swift",
        "swift_name": "AccelerationMode",
        "prefix": "VOICEVOX_ACCELERATION_MODE_",
        "style": "upper_snake",
    },
    {
        "c_name": "VoicevoxOnExistingVoiceModelId",
        "swift_file": "Enum/OnExistingVoiceModelId.swift",
        "swift_name": "OnExistingVoiceModelId",
        "prefix": "VOICEVOX_ON_EXISTING_VOICE_MODEL_ID_",
        "style": "upper_snake",
    },
    {
        "c_name": "VoicevoxUserDictWordType",
        "swift_file": "Enum/UserDictWordType.swift",
        "swift_name": "UserDictWordType",
        "prefix": "VOICEVOX_USER_DICT_WORD_TYPE_",
        "style": "lower_camel",
    },
]


class Failures:
    def __init__(self) -> None:
        self.items: list[str] = []

    def add(self, check: str, message: str) -> None:
        self.items.append(f"{check}: {message}")


def to_swift_case(name: str, style: str) -> str:
    if style == "upper_snake":
        return name
    if style == "lower_camel":
        head, *tail = name.lower().split("_")
        return head + "".join(part.capitalize() for part in tail)
    raise ValueError(f"unknown style: {style}")


def strip_block_comments(text: str) -> str:
    return re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)


def parse_c_enum(header: str, c_name: str) -> dict[str, int]:
    """ヘッダから `enum <c_name> { ... }` の case 名と値を取り出す。"""
    match = re.search(
        r"^enum\s+" + re.escape(c_name) + r"\b(.*?)^\};",
        header,
        flags=re.DOTALL | re.MULTILINE,
    )
    if match is None:
        raise LookupError(f"ヘッダに enum {c_name} が見つからない")

    body = strip_block_comments(match.group(1))
    # `#ifdef __cplusplus : int32_t #endif` の部分は `{` より前なので落とす
    body = body[body.index("{") + 1 :]

    entries: dict[str, int] = {}
    for name, value in re.findall(r"\b([A-Z][A-Z0-9_]*)\s*=\s*(-?\d+)", body):
        entries[name] = int(value)
    return entries


def parse_swift_enum(source: str, swift_name: str) -> dict[str, int]:
    """Swift のソースから `public enum <swift_name>` 本体の case と rawValue を取り出す。

    後続の extension は本体の閉じ括弧で切るため対象外になる
    (deprecated な別名エイリアスなどを拾わないようにするため)。
    """
    match = re.search(
        r"^public enum\s+" + re.escape(swift_name) + r"\s*:.*?^\}",
        source,
        flags=re.DOTALL | re.MULTILINE,
    )
    if match is None:
        raise LookupError(f"Swift に public enum {swift_name} が見つからない")

    body = strip_block_comments(match.group(0))

    entries: dict[str, int] = {}
    for name, value in re.findall(r"^\s*case\s+(\w+)\s*=\s*(-?\d+)", body, flags=re.MULTILINE):
        entries[name] = int(value)
    return entries


def check_platform_defines(header_text: dict[Path, str], failures: Failures) -> None:
    """Makefile の sed によるマクロ有効化が意図どおり効いているかを見る。

    上流がコメントの書式を変えると sed が空振りして、
    どちらのマクロも立たないヘッダが入り込む (= #error になる) ため。
    """
    check = "platform-defines"
    expectations = [
        (MAC_HEADER, LOAD, LINK),
        (IOS_HEADER, LINK, LOAD),
    ]
    for path, enabled, disabled in expectations:
        lines = header_text[path].splitlines()
        has_enabled = any(re.fullmatch(rf"#define\s+{enabled}", line.strip()) for line in lines)
        has_disabled = any(re.fullmatch(rf"#define\s+{disabled}", line.strip()) for line in lines)

        rel = path.relative_to(ROOT)
        if not has_enabled:
            failures.add(check, f"{rel} で `#define {enabled}` が有効になっていない")
        if has_disabled:
            failures.add(check, f"{rel} で `#define {disabled}` が有効になってしまっている")


def check_headers_identical(header_text: dict[Path, str], failures: Failures) -> None:
    """2 つのヘッダがマクロ切り替え行以外で同一かを見る。

    片方のプラットフォームだけ古いヘッダのまま残るのを防ぐ。
    """
    check = "headers-identical"

    def normalize(text: str) -> list[str]:
        out = []
        for line in text.splitlines():
            stripped = line.strip()
            if re.fullmatch(rf"(//)?#define\s+({LINK}|{LOAD})", stripped):
                continue
            out.append(line)
        return out

    mac = normalize(header_text[MAC_HEADER])
    ios = normalize(header_text[IOS_HEADER])
    if mac != ios:
        failures.add(
            check,
            "MAC と IOS のヘッダがマクロ切り替え行以外で食い違っている "
            "(`make` で両方を取り直してください)",
        )


def check_enums(header_text: dict[Path, str], failures: Failures) -> None:
    header = header_text[MAC_HEADER]
    for spec in ENUMS:
        check = f"enum:{spec['swift_name']}"
        try:
            c_entries = parse_c_enum(header, spec["c_name"])
            swift_source = (SWIFT_DIR / spec["swift_file"]).read_text(encoding="utf-8")
            swift_entries = parse_swift_enum(swift_source, spec["swift_name"])
        except (LookupError, OSError) as error:
            failures.add(check, str(error))
            continue

        expected = {
            to_swift_case(name[len(spec["prefix"]) :], spec["style"]): value
            for name, value in c_entries.items()
            if name.startswith(spec["prefix"])
        }
        unexpected_prefix = [n for n in c_entries if not n.startswith(spec["prefix"])]
        if unexpected_prefix:
            failures.add(
                check,
                f"接頭辞 `{spec['prefix']}` を持たない case がヘッダにある: "
                + ", ".join(sorted(unexpected_prefix)),
            )

        for name in sorted(set(expected) - set(swift_entries)):
            failures.add(check, f"Swift 側に `case {name} = {expected[name]}` が無い")
        for name in sorted(set(swift_entries) - set(expected)):
            failures.add(check, f"Swift 側の `case {name}` はヘッダに存在しない")
        for name in sorted(set(expected) & set(swift_entries)):
            if expected[name] != swift_entries[name]:
                failures.add(
                    check,
                    f"`{name}` の値がずれている (ヘッダ: {expected[name]}, "
                    f"Swift: {swift_entries[name]})",
                )


def header_functions(header: str) -> set[str]:
    """ヘッダの関数宣言から関数名を集める (doc コメント中の参照は拾わない)。"""
    text = strip_block_comments(header)
    pattern = re.compile(r"^[A-Za-z_][A-Za-z0-9_ *]*?\b(voicevox_[a-z0-9_]+)\s*\(", re.MULTILINE)
    return set(pattern.findall(text))


def swift_referenced_functions() -> set[str]:
    names: set[str] = set()
    for path in sorted(SWIFT_DIR.rglob("*.swift")):
        source = path.read_text(encoding="utf-8")
        names.update(re.findall(r"\bvoicevox_[a-z0-9_]+\b", source))
    return names


def read_allowlist() -> set[str]:
    if not UNWRAPPED_APIS.exists():
        return set()
    entries = set()
    for line in UNWRAPPED_APIS.read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            entries.add(line)
    return entries


def check_api_coverage(header_text: dict[Path, str], failures: Failures) -> None:
    """ヘッダにあって Swift から参照されていない API を検出する。

    上流のバージョンを上げたときに追加された API の取りこぼしに気づくため。
    意図的にラップしないものは Scripts/unwrapped_apis.txt に書いておく。
    """
    check = "api-coverage"
    declared = header_functions(header_text[MAC_HEADER]) | header_functions(header_text[IOS_HEADER])
    referenced = swift_referenced_functions()
    allowed = read_allowlist()

    missing = sorted(declared - referenced - allowed)
    for name in missing:
        failures.add(
            check,
            f"`{name}` が Swift からラップされていない "
            f"(意図的なら {UNWRAPPED_APIS.relative_to(ROOT)} に追記)",
        )

    stale = sorted(allowed - declared)
    for name in stale:
        failures.add(
            check,
            f"`{name}` は {UNWRAPPED_APIS.relative_to(ROOT)} にあるがヘッダに存在しない",
        )

    dangling = sorted(referenced - declared)
    for name in dangling:
        failures.add(check, f"Swift が参照する `{name}` がヘッダに存在しない")


def main() -> int:
    try:
        header_text = {path: path.read_text(encoding="utf-8") for path in (MAC_HEADER, IOS_HEADER)}
    except OSError as error:
        print(f"ヘッダを読めない: {error}", file=sys.stderr)
        return 1

    failures = Failures()
    check_platform_defines(header_text, failures)
    check_headers_identical(header_text, failures)
    check_enums(header_text, failures)
    check_api_coverage(header_text, failures)

    if failures.items:
        print("ヘッダ同期チェックに失敗しました:", file=sys.stderr)
        for item in failures.items:
            print(f"  - {item}", file=sys.stderr)
        return 1

    print("ヘッダ同期チェック: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
