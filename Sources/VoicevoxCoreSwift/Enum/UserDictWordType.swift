import Foundation

public enum UserDictWordType: Int32 {
    /// 固有名詞
    case properNoun = 0
    /// 一般名詞
    case commonNoun = 1
    /// 動詞
    case verb = 2
    /// 形容詞
    case adjective = 3
    /// 接尾辞
    case suffix = 4
}
