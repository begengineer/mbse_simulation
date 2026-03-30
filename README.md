# MBSE × 生成AI：搬送コンベア速度制御システム

生成AI（Claude）× Enterprise Architect × MATLAB/Simulink を使った **MBSE（モデルベースシステムズエンジニアリング）** の実践例です。

搬送コンベア速度制御システムを題材に、要求分析から Simulink シミュレーション検証までの一連のプロセスを実施しました。

## やったこと

```
仕様テキスト（自然言語）
    ↓ Claude + EA MCP
① ステークホルダ要求登録（SR × 5件）
    ↓ deriveReqtリンク
② システム要求登録（SysR × 10件）
    ↓ satisfyリンク
③ アーキテクチャ設計（BDD × 8ブロック）
    ↓ EA MCP → MATLAB MCP
④ Simulinkスケルトン自動生成
    ↓
⑤ シミュレーション・PIDチューニング
    ↓ MATLAB MCP → EA MCP
⑥ 検証結果をEAに反映（8/10件 Verified）
    ↓
⑦ ポート定義・IBD作成（信号線トレーサビリティ）
```

## 使用ツール

| ツール | 役割 |
|---|---|
| **Claude** | 要求の構造化・ブロック設計・スクリプト生成・判断支援 |
| **Enterprise Architect MCP** | 要求/ブロック/図の作成・トレーサビリティリンク管理 |
| **MATLAB MCP (R2025b)** | Simulinkモデル生成・シミュレーション実行・検証 |

## フォルダ構成

```
mbse_simulation/
├── 01. 要求分析/
│   └── mbseBase.qea              # Enterprise Architectモデル
├── 02. モデル/
│   ├── ConveyorSpeedControlSystem.slx  # Simulinkモデル
│   └── result_SysR*.png          # シミュレーション結果（図）
├── 03. 検証結果/
│   ├── run_all_verification_tests.m    # 全検証テスト一括実行
│   ├── plot_simulation_result.m        # 結果プロットスクリプト
│   └── result_SysR*.png          # 検証結果（図）
└── MBSE_推進まとめ.md             # プロセス全体のまとめ
```

## Simulinkモデル構成

```
ConveyorSpeedControlSystem.slx
├── 操作パネル         … 速度設定値・停止信号・ステータス出力
├── 速度コントローラ   … 偏差計算 → PID → Saturation → Switch
├── 安全監視モニタ     … 電流比較 → 緊急停止 → 停止指令
├── モータドライバ     … PWM × Gain(24V) → Switch → 電圧出力
├── DCモータ           … 速度変換 → 1次遅れ伝達関数（τ=0.5s）
├── 速度センサ         … 単位変換 + センサノイズ（σ=0.01）
└── 電流センサ         … 電圧 × Gain(0.4) → 電流値
```

## 検証結果サマリ

| 要求 | 内容 | 検証値 | 達成 |
|---|---|---|---|
| SysR-001 | 速度精度 ±2% | 偏差 0.35% | :white_check_mark: |
| SysR-002 | 起動時間 3秒以内 | 1.30秒 | :white_check_mark: |
| SysR-003 | 緊急停止 2秒以内 | 即時停止 | :white_check_mark: |
| SysR-004 | 過負荷検知・自動停止 | 0.01秒以内検知 | :white_check_mark: |
| SysR-005 | 速度範囲 0〜100 m/min | 全点偏差5%以内 | :white_check_mark: |
| SysR-006 | 操作パネル表示項目 | — | :black_square_button: |
| SysR-007 | 制御周期 10ms以下 | 固定ステップ0.01s | :white_check_mark: |
| SysR-008 | 連続24時間耐久性 | — | :black_square_button: |
| SysR-009 | 電源再投入安全初期化 | 初期速度ゼロ確認 | :white_check_mark: |
| SysR-010 | PID制御アルゴリズム | Kp/Ti/Td確定 | :white_check_mark: |

**検証完了率: 8/10件（80%）**

## 実行方法

```matlab
% MATLAB上で全検証テストを一括実行
run('03. 検証結果/run_all_verification_tests.m');
```
