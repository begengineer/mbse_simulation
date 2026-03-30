% 搬送コンベア速度制御システム - シミュレーション結果プロットスクリプト
% 生成日: 2026-03-27
% 使い方: ConveyorSpeedControlSystemのシミュレーション実行後に本スクリプトを実行

% ワークスペース変数確認
if ~exist('actualSpeed','var') || ~exist('stopSignal','var')
    error('先にConveyorSpeedControlSystemのシミュレーションを実行してください');
end

t      = actualSpeed.Time;
speed  = actualSpeed.Data;
stop   = stopSignal.Data;
target = 50;  % 目標速度 [m/min]

% 性能指標計算
idx_settle  = find(abs(speed - target) < target*0.02, 1);
settle_time = t(idx_settle);
final_speed = speed(end);
steady_pct  = abs(target - final_speed) / target * 100;
overshoot   = (max(speed) - target) / target * 100;

% グラフ描画
fig = figure('Name','搬送コンベア速度制御 シミュレーション結果', ...
    'Position',[100 100 900 600]);

%% 上段: 速度応答グラフ
subplot(2,1,1);
plot(t, ones(size(t))*target,        'b--', 'LineWidth',1.5, 'DisplayName','目標速度'); hold on;
plot(t, speed,                        'r-',  'LineWidth',2,   'DisplayName','実速度');
plot(t, ones(size(t))*(target*1.02), 'g:',  'LineWidth',1,   'DisplayName','+2%許容帯');
plot(t, ones(size(t))*(target*0.98), 'g:',  'LineWidth',1,   'DisplayName','-2%許容帯');
if ~isnan(settle_time)
    xline(settle_time,'k--',sprintf('整定時間 %.2fs', settle_time),'LabelVerticalAlignment','bottom');
end
xlabel('時間 [s]'); ylabel('速度 [m/min]');
title(sprintf('速度応答（PID制御） | 精度:±%.2f%% | 整定:%.2fs | オーバーシュート:%.2f%%', ...
    steady_pct, settle_time, overshoot));
legend('Location','southeast'); grid on;
ylim([0 max(speed)*1.2]);

%% 下段: 安全監視グラフ
subplot(2,1,2);
plot(t, stop, 'm-', 'LineWidth',2);
xlabel('時間 [s]'); ylabel('停止指令');
title('安全監視モニタ出力（0=正常, 1=停止）');
ylim([-0.1 1.1]); yticks([0 1]); grid on;

%% 保存
savePath = fullfile(fileparts(which('ConveyorSpeedControlSystem')), 'simulation_result.png');
saveas(fig, savePath);
fprintf('グラフ保存完了: %s\n', savePath);
fprintf('--- 性能指標 ---\n');
fprintf('目標速度    : %.1f m/min\n', target);
fprintf('最終速度    : %.3f m/min\n', final_speed);
fprintf('定常偏差    : %.2f%%\n', steady_pct);
fprintf('整定時間    : %.2f 秒\n', settle_time);
fprintf('オーバーシュート: %.2f%%\n', overshoot);
