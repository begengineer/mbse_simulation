% ============================================================
% 搬送コンベア速度制御システム - 全検証テストスクリプト
% 実行すると全SysR検証シミュレーションが順番に実行され
% 各テストのプロットが自動表示されます
% 生成日: 2026-03-27
% ============================================================

modelName = 'ConveyorSpeedControlSystem';
if ~bdIsLoaded(modelName), load_system(modelName); end
savedir = fileparts(which([modelName '.slx']));
if isempty(savedir), savedir = 'C:\Users\anpan\OneDrive\デスクトップ\Developer\mbse\03. 検証結果'; end

results = struct();
fprintf('\n========================================\n');
fprintf('  搬送コンベア速度制御システム 全検証テスト\n');
fprintf('========================================\n\n');

% ============================================================
% テスト1: SysR-001/002 速度応答（PID制御）
% ============================================================
fprintf('[テスト1] SysR-001/002: 速度応答テスト...\n');
set_param([modelName '/操作パネル/速度設定値'],'Value','50');
set_param([modelName '/操作パネル/停止信号'],'Value','0');
set_param([modelName '/電流センサ/電流換算'],'Gain','0.4');
save_system(modelName);
simOut = sim(modelName,'StopTime','30');
t   = simOut.actualSpeed.Time;
spd = simOut.actualSpeed.Data;
stp = simOut.stopSignal.Data;
target = 50;
idx_s = find(abs(spd-target)<target*0.02,1);
settle_time = t(idx_s);
steady_pct  = abs(target-spd(end))/target*100;
overshoot   = max(0,(max(spd)-target)/target*100);
results.SysR001 = steady_pct  <= 2.0;
results.SysR002 = settle_time <= 3.0;

figure('Name','[SysR-001/002] 速度応答テスト','Position',[50 500 860 420]);
subplot(2,1,1);
plot(t,ones(size(t))*target,'b--','LineWidth',1.5,'DisplayName','目標速度'); hold on;
plot(t,spd,'r-','LineWidth',2,'DisplayName','実速度');
plot(t,ones(size(t))*(target*1.02),'g:','LineWidth',1,'DisplayName','+2%帯');
plot(t,ones(size(t))*(target*0.98),'g:','LineWidth',1,'HandleVisibility','off');
xline(settle_time,'k--',sprintf('整定 %.2fs',settle_time),'LabelVerticalAlignment','bottom');
ylabel('速度 [m/min]');
title(sprintf('SysR-001/002 速度応答 | 精度:±%.2f%%(要求±2%%) | 整定:%.2fs(要求3s以内)',steady_pct,settle_time));
legend('Location','southeast'); grid on; ylim([0 70]);
subplot(2,1,2);
plot(t,stp,'m-','LineWidth',2);
ylabel('停止指令'); xlabel('時間 [s]');
title('安全監視出力（0=正常）'); ylim([-0.1 1.1]); yticks([0 1]); grid on;
saveas(gcf, fullfile(savedir,'result_SysR001_002.png'));
fprintf('  SysR-001 速度精度: %.2f%% → %s\n', steady_pct,  string(results.SysR001));
fprintf('  SysR-002 整定時間: %.2fs → %s\n',  settle_time, string(results.SysR002));

% ============================================================
% テスト2: SysR-003 緊急停止テスト
% ============================================================
fprintf('\n[テスト2] SysR-003: 緊急停止テスト...\n');
set_param([modelName '/操作パネル/停止信号'],'Value','1');
save_system(modelName);
simOut3 = sim(modelName,'StopTime','5');
t3  = simOut3.speed_ES.Time;
s3  = simOut3.speed_ES.Data;
idx3 = find(s3 < 0.5, 1);
stop_time = t3(idx3);
results.SysR003 = stop_time <= 2.0;

figure('Name','[SysR-003] 緊急停止テスト','Position',[50 50 860 300]);
plot(t3,s3,'r-','LineWidth',2,'DisplayName','実速度'); hold on;
xline(stop_time,'k--',sprintf('停止完了 %.2fs',stop_time),'LabelVerticalAlignment','bottom');
yline(0.5,'b:','停止判定ライン');
xlabel('時間 [s]'); ylabel('速度 [m/min]');
title(sprintf('SysR-003 緊急停止テスト | 停止時間:%.2fs (要求2秒以内) → %s',stop_time,string(results.SysR003)));
legend('Location','northeast'); grid on;
saveas(gcf, fullfile(savedir,'result_SysR003.png'));
fprintf('  SysR-003 緊急停止: %.2fs → %s\n', stop_time, string(results.SysR003));
set_param([modelName '/操作パネル/停止信号'],'Value','0');
save_system(modelName);

% ============================================================
% テスト3: SysR-004 過負荷検知テスト
% ============================================================
fprintf('\n[テスト3] SysR-004: 過負荷検知テスト...\n');
set_param([modelName '/電流センサ/電流換算'],'Gain','30');
save_system(modelName);
simOut4 = sim(modelName,'StopTime','10');
t4   = simOut4.stopSignal.Time;
sig4 = simOut4.stopSignal.Data;
spd4 = simOut4.speed_ES.Data;
idx4 = find(sig4>0.5,1);
detect_time = t4(idx4);
results.SysR004 = ~isempty(idx4);

figure('Name','[SysR-004] 過負荷検知テスト','Position',[920 500 860 420]);
subplot(2,1,1);
plot(t4,spd4,'r-','LineWidth',2);
if results.SysR004
    xline(detect_time,'k--',sprintf('過負荷検知 %.2fs',detect_time));
end
ylabel('速度 [m/min]'); title('速度（過負荷時）'); grid on;
subplot(2,1,2);
plot(t4,sig4,'m-','LineWidth',2);
if results.SysR004
    xline(detect_time,'k--',sprintf('停止指令発令 %.2fs',detect_time));
end
xlabel('時間 [s]'); ylabel('停止指令');
title(sprintf('SysR-004 過負荷検知 | 検知時刻:%.2fs → %s',detect_time,string(results.SysR004)));
ylim([-0.1 1.1]); yticks([0 1]); grid on;
saveas(gcf, fullfile(savedir,'result_SysR004.png'));
fprintf('  SysR-004 過負荷検知: %.2fs → %s\n', detect_time, string(results.SysR004));
set_param([modelName '/電流センサ/電流換算'],'Gain','0.4');
save_system(modelName);

% ============================================================
% テスト4: SysR-005 速度範囲テスト
% ============================================================
fprintf('\n[テスト4] SysR-005: 速度範囲テスト...\n');
test_speeds = [25 50 75 100];
final_speeds = zeros(size(test_speeds));
for i = 1:length(test_speeds)
    set_param([modelName '/操作パネル/速度設定値'],'Value',num2str(test_speeds(i)));
    save_system(modelName);
    sOut = sim(modelName,'StopTime','20');
    final_speeds(i) = sOut.speed_ES.Data(end);
end
errs = abs(test_speeds - final_speeds)./test_speeds*100;
results.SysR005 = all(errs <= 5.0);

figure('Name','[SysR-005] 速度範囲テスト','Position',[920 50 860 350]);
bar(test_speeds, final_speeds, 0.5, 'FaceColor',[0.3 0.6 0.9]);
hold on;
errorbar(test_speeds, test_speeds, test_speeds*0.05, 'k.', 'LineWidth',1.5);
plot(test_speeds, test_speeds,'r--','LineWidth',1.5,'DisplayName','目標値');
for i=1:length(test_speeds)
    text(test_speeds(i), final_speeds(i)+1, sprintf('%.1f\n(%.2f%%)',final_speeds(i),errs(i)),'HorizontalAlignment','center','FontSize',9);
end
xlabel('設定速度 [m/min]'); ylabel('実測速度 [m/min]');
title(sprintf('SysR-005 速度範囲テスト (0～100 m/min) → %s',string(results.SysR005)));
legend({'実測値','±5%許容帯','目標値'},'Location','northwest'); grid on;
saveas(gcf, fullfile(savedir,'result_SysR005.png'));
fprintf('  SysR-005 速度範囲: %s\n', string(results.SysR005));
set_param([modelName '/操作パネル/速度設定値'],'Value','50');
save_system(modelName);

% ============================================================
% テスト5: SysR-009 電源再投入・安全初期化テスト
% ============================================================
fprintf('\n[テスト5] SysR-009: 電源再投入テスト...\n');
simOut9 = sim(modelName,'StopTime','10');
t9  = simOut9.speed_ES.Time;
s9  = simOut9.speed_ES.Data;
st9 = simOut9.stopSignal.Data;
results.SysR009 = abs(s9(1)) < 1.0 && st9(1) == 0;

figure('Name','[SysR-009] 電源再投入テスト','Position',[50 50 860 300]);
plot(t9,s9,'r-','LineWidth',2,'DisplayName','実速度'); hold on;
yline(1.0,'b:','安全判定ライン(1 m/min)');
xline(0.1,'k--','初期確認点');
xlabel('時間 [s]'); ylabel('速度 [m/min]');
title(sprintf('SysR-009 電源再投入安全初期化 | 初期速度:%.3f m/min → %s',s9(1),string(results.SysR009)));
legend('Location','southeast'); grid on;
saveas(gcf, fullfile(savedir,'result_SysR009.png'));
fprintf('  SysR-009 安全初期化: 初期速度=%.3f m/min → %s\n', s9(1), string(results.SysR009));

% ============================================================
% 全テスト結果サマリ表示
% ============================================================
fprintf('\n========================================\n');
fprintf('          全検証テスト結果サマリ\n');
fprintf('========================================\n');
names = {'SysR-001 速度精度±2%','SysR-002 起動時間3秒','SysR-003 緊急停止2秒','SysR-004 過負荷検知','SysR-005 速度範囲','SysR-009 安全初期化'};
passed = [results.SysR001, results.SysR002, results.SysR003, results.SysR004, results.SysR005, results.SysR009];
for i=1:length(names)
    if passed(i)
        fprintf('  ✓ %s: PASS\n', names{i});
    else
        fprintf('  ✗ %s: FAIL\n', names{i});
    end
end
fprintf('----------------------------------------\n');
fprintf('  合格: %d/%d件\n', sum(passed), length(passed));
fprintf('========================================\n');
fprintf('\nグラフ保存先: %s\n', savedir);
