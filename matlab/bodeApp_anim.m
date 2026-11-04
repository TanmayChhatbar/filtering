function bodeApp_anim
% init figure and cols
fig = uifigure('Name', 'RC filter sim', 'Position', [100 100 1200 720]);
fig.WindowState = 'maximized';
main = uigridlayout(fig, [1 2]);
main.ColumnWidth = {400, '1x'};
main.Padding = [20 20 20 20];

% controls
controls = uigridlayout(main, [20 1]);
controls.RowHeight = {32, 22, 30, 22, 30, 100, 22, 30, 22, 30, 22, 30, 22, 30, 32, 36, 32, 40, '1x', 40};
controls.Scrollable = 'on';
controls.Padding = [0 0 15 0];
uilabel(controls, 'Text', 'RC filter sim', 'FontWeight', 'bold');
uilabel(controls, 'Text', 'Filter 1');
type1 = uidropdown(controls, 'Items', {'LPF', 'HPF'}, 'Value', 'LPF');
uilabel(controls, 'Text', 'Filter 2');
type2 = uidropdown(controls, 'Items', {'LPF', 'HPF', 'None'}, 'Value', 'None');
uiimage(controls, 'ImageSource', fullfile('pcb-bg.png'), 'ScaleMethod', 'fit');
r1label = uilabel(controls); r1 = uislider(controls, 'Limits', [2 6], 'Value', 4, 'MajorTicks', []);
c1label = uilabel(controls); c1 = uislider(controls, 'Limits', [-9 -5], 'Value', -7, 'MajorTicks', []);
r2label = uilabel(controls); r2 = uislider(controls, 'Limits', [2 6], 'Value', 4, 'MajorTicks', []);
c2label = uilabel(controls); c2 = uislider(controls, 'Limits', [-9 -5], 'Value', -7, 'MajorTicks', []);
ramp1label = uilabel(controls, 'Text', 'Amplifier ground connection');
ramp1 = uibutton(controls, 'state', 'Text', 'Ground disconnected');
ramp2label = uilabel(controls); ramp2 = uislider(controls, 'Limits', [0 10], 'Value', 0);
uilabel(controls, 'Text', '');
magnitudeToggle = uibutton(controls, 'state', 'Text', 'Magnitude: dB');

plots = uigridlayout(main, [4 1]);
plots.RowHeight = {'1x', '1x', 65, '1.3x'};
plots.Padding = [0 0 0 0];
gainAx = uiaxes(plots); phaseAx = uiaxes(plots);
freqPanel = uigridlayout(plots, [2 1]);
freqPanel.RowHeight = {22, 25}; freqPanel.Padding = [55 0 30 0];
freqLabel = uilabel(freqPanel, 'HorizontalAlignment', 'center');
freqSlider = uislider(freqPanel, 'Limits', [0 6], 'Value', 3, 'MajorTicks', 0:6, ...
    'MajorTickLabels', {'1', '10', '100', '1k', '10k', '100k', '1M'});
timeAx = uiaxes(plots);

% plots
f = logspace(0, 6, 101);
R1 = 10^r1.Value; C1 = 10^c1.Value;
R2 = 10^r2.Value; C2 = 10^c2.Value;
selected = 10^freqSlider.Value;
H = response(f, R1, C1, type1.Value).*response(f, R2, C2, type2.Value);
p.bode.gain = semilogx(gainAx, f, 20*log10(abs(H)), 'LineWidth', 1.5); hold(gainAx, 'on');
ylim(gainAx, [-80 20])
p.selected(1) = xline(gainAx, selected, '--r'); hold(gainAx, 'off'); grid(gainAx, 'on');
title(gainAx, 'Bode plot'); ylabel(gainAx, 'Gain [dB]'); xlim(gainAx, [1 1e6]);
p.bode.phase = semilogx(phaseAx, f, unwrap(angle(H))*180/pi, 'LineWidth', 1.5); hold(phaseAx, 'on');
p.selected(2) = xline(phaseAx, selected, '--r'); hold(phaseAx, 'off'); grid(phaseAx, 'on');
ylabel(phaseAx, 'Phase [degrees]'); xlabel(phaseAx, 'Frequency [Hz]'); xlim(phaseAx, [1 1e6]);
% Each marker shows the cutoff of an individual RC stage.
cutoffColors = [0 0.45 0.74; 0.49 0.18 0.56];
for k = 1:2
    p.cutoff(k, 1) = xline(gainAx, 1, ':', 'Color', cutoffColors(k, :), ...
        'LineWidth', 1.5, 'LabelVerticalAlignment', 'top');
    p.cutoff(k, 2) = xline(phaseAx, 1, ':', 'Color', cutoffColors(k, :), ...
        'LineWidth', 1.5, 'LabelVerticalAlignment', 'top');
end
p.cutoff(2, 1).LabelVerticalAlignment = 'bottom';
p.cutoff(2, 2).LabelVerticalAlignment = 'bottom';
t = linspace(0, 2/selected, 201);
chosen = response(selected, R1, C1, type1.Value).*response(selected, R2, C2, type2.Value);
p.time.input = plot(timeAx, t*1000, sin(2*pi*selected*t), 'LineWidth', 1.5);
hold(timeAx, 'on')
p.time.output = plot(timeAx, t*1000, abs(chosen)*sin(2*pi*selected*t+angle(chosen)), 'LineWidth', 1.5);
p.time.inputPeak = xline(timeAx, 0, '-.', 'Color', [.5 .5 .5]);
p.time.outputPeak = xline(timeAx, 0, '-.', 'Color', [.5 .5 .5]);
p.time.inputAmp = yline(timeAx, 1, '-.', 'Color', [.5 .5 .5]);
p.time.outputAmp = yline(timeAx, 0, '-.', 'Color', [.5 .5 .5]);
yl = ylim(timeAx);
p.time.delayText = text(timeAx, 0, 0, '', 'Color', [.35 .35 .35], ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
p.time.ratioText = text(timeAx, 0, 0, '', 'Color', [.35 .35 .35], ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
% hold(timeAx, 'off')
% grid(timeAx, 'on');
title(timeAx, 'Steady-state sine response');
xlabel(timeAx, 'Time [seconds]'); ylabel(timeAx, 'Amplitude [-]');
legend(timeAx, [p.time.input p.time.output], {'Input', 'Output'}, 'Location', 'northeast'); ylim(timeAx, [-1.1 1.1]);
for component = [type1 type2 r1 c1 r2 c2 freqSlider ramp1 ramp2 magnitudeToggle]
    component.ValueChangedFcn = @updatePlots;
end
for component = [r1 c1 r2 c2 freqSlider ramp2]
    component.ValueChangingFcn = @updatePlots;
end
components = findall(fig, '-property', 'FontSize');
set(components, 'FontSize', 20);
components = findall(fig, 'Type', 'Line');
set(components, 'LineWidth', 4);
p.time.delay = plot(timeAx, [0 0], (yl*[.95; .05]).*[1 1], '--', 'Color', [.5 .5 .5], 'linewidth', 1, 'handlevisibility', 'off');
p.time.ratio = plot(timeAx, [0 0], [0 0], '--', 'Color', [.5 .5 .5], 'linewidth', 1, 'handlevisibility', 'off');

updatePlots();

% LPF frequency sweep
n = 120;
type1.Value = 'LPF';
type2.Value = 'None';
sweeper = freqSlider;
lastval = sweeper.Value;
sweep = linspace(sweeper.Limits(1), sweeper.Limits(2), n);
mkdir('fig_freqsweep_LPF');
for i = 1:length(sweep)
    sweeper.Value = sweep(i);
    updatePlots();
    drawnow
    exportapp(fig, "fig_freqsweep_LPF/"+sprintf("%03d", i)+".png")
end
sweeper.Value = lastval;

% LPF fc sweep
type1.Value = 'LPF';
type2.Value = 'None';
sweeper = r1;
lastval = sweeper.Value;
sweep = linspace(sweeper.Limits(1), sweeper.Limits(2), n);
mkdir('fig_r1_LPF');
for i = 1:length(sweep)
    sweeper.Value = sweep(i);
    updatePlots();
    drawnow
    exportapp(fig, "fig_r1_LPF/"+sprintf("%03d", i)+".png")
end
sweeper.Value = lastval;

% HPF fc sweep
type1.Value = 'HPF';
type2.Value = 'None';
sweeper = r1;
lastval = sweeper.Value;
sweep = linspace(sweeper.Limits(1), sweeper.Limits(2), n);
mkdir('fig_r1_HPF');
for i = 1:length(sweep)
    sweeper.Value = sweep(i);
    updatePlots();
    drawnow
    exportapp(fig, "fig_r1_HPF/"+sprintf("%03d", i)+".png")
end
sweeper.Value = lastval;

% bandpass
type1.Value = 'LPF';
type2.Value = 'HPF';
sweeper = r1;
lastval = sweeper.Value;
sweep = linspace(sweeper.Limits(1), sweeper.Limits(2), n);
mkdir('fig_bandpass1');
for i = 1:length(sweep)
    sweeper.Value = sweep(i);
    r2.Value = max(sweep(i), r2.Limits(1));
    updatePlots();
    drawnow
    exportapp(fig, "fig_bandpass1/"+sprintf("%03d", i)+".png")
end
sweeper.Value = lastval;

% bandpass2
type1.Value = 'LPF';
type2.Value = 'HPF';
sweeper = r1;
lastval = sweeper.Value;
sweep = linspace(sweeper.Limits(1), sweeper.Limits(2), n);
mkdir('fig_bandpass2');
for i = 1:length(sweep)
    sweeper.Value = sweep(i);
    r2.Value = min(sweep(i)+.5, r2.Limits(2));
    updatePlots();
    drawnow
    exportapp(fig, "fig_bandpass2/"+sprintf("%03d", i)+".png")
end
sweeper.Value = lastval;

% gain
type1.Value = 'LPF';
type2.Value = 'None';
ramp1.Value = 1;
sweeper = ramp2;
lastval = sweeper.Value;
sweep = linspace(sweeper.Limits(1), sweeper.Limits(2), n);
mkdir('fig_gain');
for i = 1:length(sweep)
    sweeper.Value = sweep(i);
    updatePlots();
    drawnow
    exportapp(fig, "fig_gain/"+sprintf("%03d", i)+".png")
end
sweeper.Value = lastval;

% compile to videos
df = dir('./');
df = df(3:end);
df = df([df(:).isdir] & string({df(:).name}) ~= "fig_vid" & string({df(:).name}) ~= "backup");
mkdir('fig_vid')
for i = 1:length(df)
    image_names = "./"+df(i).name+"/%03d.png";
    output_name = "./fig_vid/"+df(i).name+".mp4";
    output_name_reversed = "./fig_vid/"+df(i).name+"-reversed.mp4";
    system("ffmpeg -framerate 24 -i """+image_names+""" -y  -vf """"pad=2560:1440:(ow-iw)/2:(oh-ih)/2:0x212121"""" -c:v libx264 -crf 0 -pix_fmt yuv420p """+output_name+"""");
    system("ffmpeg -i "+output_name+" -vf reverse -c:v libx264 -crf 0 "+output_name_reversed);
end

% combine
sequence = ["freqsweep_LPF", "r1_LPF", "r1_HPF", "bandpass1", "bandpass2", "gain"];
sequence = [sequence; sequence+"-reversed"];
sequence = reshape(sequence, 1, []);
video_files = "file '" + fullfile("fig_" + sequence + ".mp4")' + "'";
writematrix(strrep(video_files, '\', '/'), "fig_vid/filelist.txt")

cc = sprintf('ffmpeg -f concat -safe 0 -i "%s" -c copy -y "%s"', "fig_vid/filelist.txt", "fig_vid/combined.mp4");
system(cc);

    function updatePlots(source, event)
        % ValueChanging events contain the current value before it is committed.
        values = [r1.Value c1.Value r2.Value c2.Value freqSlider.Value ramp2.Value];
        if nargin > 1 && isprop(event, 'Value')
            sliders = [r1 c1 r2 c2 freqSlider ramp2];
            for k1 = 1:numel(sliders)
                if isequal(source, sliders(k1)), values(k1) = event.Value; end
            end
        end
        R1 = 10^values(1); C1 = 10^values(2);
        R2 = 10^values(3); C2 = 10^values(4);
        selected = 10^values(5);
        ratio = values(6);
        if ramp1.Value
            amplifierGain = 1 + ratio;
            ramp1.Text = 'Ground connected';
        else
            amplifierGain = 1;
            ramp1.Text = 'Ground disconnected';
        end
        r1label.Text = sprintf('R1: %.2f kOhm', R1/1e3);
        c1label.Text = sprintf('C1: %.2f nF', C1/1e-9);
        ramp2label.Text = sprintf('R_amp2 / R_amp1: %.2f   (G=%.2f)', ratio, amplifierGain);
        r2label.Text = sprintf('R4: %.2f kOhm', R2/1e3);
        c2label.Text = sprintf('C2: %.2f nF', C2/1e-9);
        freqLabel.Text = sprintf('Selected frequency: %.2f Hz', selected);

        cutoff = [1/(2*pi*R1*C1), 1/(2*pi*R2*C2)];
        active = [true, ~strcmp(type2.Value, 'None')];
        bounds = [min(1, min(cutoff(active))/2), max(1e6, max(cutoff(active))*2)];
        f = logspace(log10(bounds(1)), log10(bounds(2)), 301);
        t = linspace(0, 2/selected, 201);

        H = amplifierGain.*response(f, R1, C1, type1.Value).*response(f, R2, C2, type2.Value);
        chosen = amplifierGain.*response(selected, R1, C1, type1.Value).*response(selected, R2, C2, type2.Value);

        p.selected(1).Value = selected;
        p.selected(2).Value = selected;
        for k2 = 1:2
            for ax = 1:2
                p.cutoff(k2, ax).Value = cutoff(k2);
                p.cutoff(k2, ax).Label = sprintf('f_%d=%.2f Hz', k2, cutoff(k2));
                if active(k2)
                    p.cutoff(k2, ax).Visible = 'on';
                else
                    p.cutoff(k2, ax).Visible = 'off';
                end
            end
        end
        xlim(gainAx, bounds);
        xlim(phaseAx, bounds);

        p.bode.gain.XData = f;
        if magnitudeToggle.Value
            p.bode.gain.YData = abs(H);
            ylabel(gainAx, 'Magnitude [-]');
            magnitudeToggle.Text = 'Magnitude: absolute';
        else
            p.bode.gain.YData = 20*log10(abs(H));
            ylabel(gainAx, 'Gain [dB]');
            magnitudeToggle.Text = 'Magnitude: dB';
        end
        p.bode.phase.XData = f;
        p.bode.phase.YData = unwrap(angle(H))*180/pi;

        p.time.input.XData = t;
        p.time.input.YData = sin(2*pi*selected*t);
        p.time.output.XData = t;
        p.time.output.YData = abs(chosen)*sin(2*pi*selected*t+angle(chosen));
        phase = angle(chosen);
        delay = -phase/(2*pi*selected);
        inputPeak = 0.25/selected;
        if inputPeak + delay < 0
            inputPeak = inputPeak + 1/selected;
        end
        p.time.inputPeak.Value = inputPeak;
        p.time.outputPeak.Value = inputPeak + delay;
        title(timeAx, sprintf('Phase: %.1f deg', -phase*180/pi));
        xlim(timeAx, [0 t(end)])
        ylim(timeAx, 1.1*max(1, abs(chosen))*[-1 1]);
        yl = ylim(timeAx);
        delayHeight = yl(1) + 0.08*diff(yl);
        p.time.delay.XData = [inputPeak inputPeak + delay];
        p.time.delay.YData = [delayHeight delayHeight];
        p.time.delayText.Position = [inputPeak + delay/2 delayHeight 0];
        p.time.delayText.String = sprintf('Phase = %.1f deg', -phase*180/pi);
        ratioX = 0.85/selected;
        p.time.ratio.XData = [ratioX ratioX];
        outputPeak = abs(chosen);
        p.time.ratio.YData = [1 outputPeak];
        p.time.inputAmp.Value = 1;
        p.time.outputAmp.Value = outputPeak;
        p.time.ratioText.Position = [ratioX (1 + abs(chosen))/2 0];
        p.time.ratioText.String = sprintf('G_f = %.2f', abs(chosen));
    end
end

function H = response(f, R, C, kind)
s = 1i*2*pi*f*R*C;
if strcmp(kind, 'HPF')
    H = s./(1+s);
elseif strcmp(kind, 'LPF')
    H = 1./(1+s);
else
    H = 1;
end
end
