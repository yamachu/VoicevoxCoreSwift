import Foundation

public enum AccelerationMode: Int32 {
  /**
   * 実行環境に合った適切なハードウェアアクセラレーションモードを選択する
   */
  case AUTO = 0
  /**
   * ハードウェアアクセラレーションモードを"CPU"に設定する
   */
  case CPU = 1
  /**
   * ハードウェアアクセラレーションモードを"GPU"に設定する
   */
  case GPU = 2
}
