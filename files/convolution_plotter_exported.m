classdef convolution_plotter_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        Slider                   matlab.ui.control.Slider
        ConvolveButton           matlab.ui.control.Button
        ConvolutionPlotterLabel  matlab.ui.control.Label
        Label                    matlab.ui.control.Label
        x2tDropDown              matlab.ui.control.DropDown
        x2tDropDownLabel         matlab.ui.control.Label
        x1tDropDown              matlab.ui.control.DropDown
        x1tDropDownLabel         matlab.ui.control.Label
        UIAxes                   matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        dt
        t1
        rt
        t2
        gt
        t3
        yt
        dplot
        idx
        value1
        value2
        changingValue
        ct
        ct_x
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %Works Cited
            %[1]  Parisi, Phil. “Phil Parisi” Youtube. https://www.youtube.com/watch?v=hcyy144Gu60&t=87s (accessed September 24, 2024).
            %[2]  MathWorks. "MatLab Documentation."
            %https://www.mathworks.com/help/releases/R2024b/index.html?s_tid=CRUX_lftnav
            %(accessed September 19, 2024).

            %The convolution function can only be done with discrete values therefore we must define a time interval => dt
            app.dt = 0.1;

            %Define the square wave as a matrix of 1's from -1 to 1 and 0's everywhere else
            app.t1 = -2:app.dt:2;
            app.rt = [0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0];

            %Define the triangle wave by writing out all values from -1 to 1
            app.t2 = -2:app.dt:2;
            app.gt = [0 0 0 0 0 0 0 0 0 0 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0 0 0 0 0 0 0 0 0 0 0];

            %Define the dirac function => from the Matlab documentation
            app.t3 = -2:app.dt:2;
            app.yt = dirac(app.t3);
            app.idx = app.yt == Inf; % find Inf
            app.yt(app.idx) = 10;     % set Inf to finite value


            app.x1tDropDown.Value = "";  %initialize drop downs
            app.x2tDropDown.Value = "";

        end

        % Value changed function: x2tDropDown
        function x2tDropDownValueChanged(app, event)
            app.value2 = app.x2tDropDown.Value;  %get the drop down value

            if app.value2 == "Rectangle Pulse" %if else converts the drop down string to the correct function and plots it
                app.value2 = app.rt; 
                plot(app.UIAxes, app.t1, app.value2);
            elseif app.value2 == "Triangle Pulse" 
                app.value2 = app.gt;
                plot(app.UIAxes, app.t2, app.value2);
            else  
                app.value2 = app.yt;
                plot(app.UIAxes, app.t3, app.value2*app.dt); %scale the dirac function
            end

        end

        % Value changed function: x1tDropDown
        function x1tDropDownValueChanged(app, event)
            app.value1 = app.x1tDropDown.Value;  %get the drop down value

            if app.value1 == "Rectangle Pulse" %if else converts the drop down string to the correct function and plots it
                app.value1 = app.rt; 
                plot(app.UIAxes, app.t1, app.value1);
            elseif app.value1 == "Triangle Pulse" 
                app.value1 = app.gt;
                plot(app.UIAxes, app.t2, app.value1);
            else  
                app.value1 = app.yt;
                plot(app.UIAxes, app.t3, app.value1*app.dt) %scale the dirac function
            end

            hold(app.UIAxes, "on");

        end

        % Button pushed function: ConvolveButton
        function ConvolveButtonPushed(app, event)
            %Get convolution of the two chosen functions
            app.ct = app.dt*conv(app.value1,app.value2); %Multiply by dt to scale the function in the y direction
            app.ct_x = app.dt.*(1:length(app.ct)) - 4.1; %Multiply by dt to scale the function in the x direction, then subtract by 4.1
            % (because there are 41 elements at an incriment of 0.1) to center it
     
            if all(app.value1 == app.yt) && all(app.value2 == app.yt)  %if both inputs are the delta function, scale the convolution
                app.ct = app.ct*app.dt;
            end
            plot(app.UIAxes, app.ct_x, app.ct);  %plot the convolution from -2 to 2
            xlim(app.UIAxes, [-2, 2]);
            hold(app.UIAxes, "off");

            app.x1tDropDown.Value = "";  %reset the drop down boxes
            app.x2tDropDown.Value = "";

            if app.value1 == app.yt  %rescale the delta function to make it look pretty :)
                app.value1 = app.value1 * app.dt;
            end
            if app.value2 == app.yt
                app.value2 = app.value2 * app.dt;
            end
            

        end

        % Value changing function: Slider
        function SliderValueChanging(app, event)
            app.changingValue = 10*round(event.Value, 1); %because we have an array of values from 2 to -2 (total of 41 values), we multiply the slider position
            %by 10 to get the index of the value
            
            temp = circshift(app.value1, app.changingValue);  %Shift the indeces of value1 (x1) based on where the slider is
            temp([1:app.changingValue, end+app.changingValue + 1:end]) = 0;  %for the elements that were rotated to the other side, make them 0

            plot(app.UIAxes, app.t1, temp);
            
            hold(app.UIAxes, "on")
            xlim(app.UIAxes, [-2, 2]);

            plot(app.UIAxes, app.t1, app.value2);  %plot value2 (x2)
  
            temp2 = app.ct; 
            temp2(app.changingValue + 41:1:length(temp2)) = 0;  %for the convolution, make all the values after the index of the slider 0
            plot(app.UIAxes, app.ct_x, temp2);

            hold(app.UIAxes, "off")            

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 532];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            xlabel(app.UIAxes, 't')
            ylabel(app.UIAxes, 'y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [14 136 613 343];

            % Create x1tDropDownLabel
            app.x1tDropDownLabel = uilabel(app.UIFigure);
            app.x1tDropDownLabel.HorizontalAlignment = 'right';
            app.x1tDropDownLabel.Position = [210 115 29 22];
            app.x1tDropDownLabel.Text = 'x1(t)';

            % Create x1tDropDown
            app.x1tDropDown = uidropdown(app.UIFigure);
            app.x1tDropDown.Items = {'', 'Rectangle Pulse', 'Triangle Pulse', 'Delta Function'};
            app.x1tDropDown.ValueChangedFcn = createCallbackFcn(app, @x1tDropDownValueChanged, true);
            app.x1tDropDown.Position = [254 115 42 16];
            app.x1tDropDown.Value = 'Delta Function';

            % Create x2tDropDownLabel
            app.x2tDropDownLabel = uilabel(app.UIFigure);
            app.x2tDropDownLabel.HorizontalAlignment = 'right';
            app.x2tDropDownLabel.Position = [349 115 29 22];
            app.x2tDropDownLabel.Text = 'x2(t)';

            % Create x2tDropDown
            app.x2tDropDown = uidropdown(app.UIFigure);
            app.x2tDropDown.Items = {'', 'Rectangle Pulse', 'Triangle Pulse', 'Delta Function'};
            app.x2tDropDown.ValueChangedFcn = createCallbackFcn(app, @x2tDropDownValueChanged, true);
            app.x2tDropDown.Position = [393 115 42 16];
            app.x2tDropDown.Value = '';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.FontSize = 36;
            app.Label.Position = [314 90 14 47];
            app.Label.Text = '*';

            % Create ConvolutionPlotterLabel
            app.ConvolutionPlotterLabel = uilabel(app.UIFigure);
            app.ConvolutionPlotterLabel.FontSize = 36;
            app.ConvolutionPlotterLabel.Position = [160 478 313 47];
            app.ConvolutionPlotterLabel.Text = 'Convolution Plotter';

            % Create ConvolveButton
            app.ConvolveButton = uibutton(app.UIFigure, 'push');
            app.ConvolveButton.ButtonPushedFcn = createCallbackFcn(app, @ConvolveButtonPushed, true);
            app.ConvolveButton.Position = [271 68 100 23];
            app.ConvolveButton.Text = 'Convolve!';

            % Create Slider
            app.Slider = uislider(app.UIFigure);
            app.Slider.Limits = [-2 2];
            app.Slider.ValueChangingFcn = createCallbackFcn(app, @SliderValueChanging, true);
            app.Slider.MinorTicks = [-2 -1.96 -1.92 -1.88 -1.84 -1.8 -1.76 -1.72 -1.68 -1.64 -1.6 -1.56 -1.52 -1.48 -1.44 -1.4 -1.36 -1.32 -1.28 -1.24 -1.2 -1.16 -1.12 -1.08 -1.04 -1 -0.96 -0.92 -0.88 -0.84 -0.8 -0.76 -0.72 -0.68 -0.64 -0.6 -0.56 -0.52 -0.48 -0.44 -0.4 -0.36 -0.32 -0.28 -0.24 -0.2 -0.16 -0.12 -0.0800000000000001 -0.04 0 0.04 0.0800000000000001 0.12 0.16 0.2 0.24 0.28 0.32 0.36 0.4 0.44 0.48 0.52 0.56 0.6 0.64 0.68 0.72 0.76 0.8 0.84 0.88 0.92 0.96 1 1.04 1.08 1.12 1.16 1.2 1.24 1.28 1.32 1.36 1.4 1.44 1.48 1.52 1.56 1.6 1.64 1.68 1.72 1.76 1.8 1.84 1.88 1.92 1.96 2];
            app.Slider.Position = [38 44 565 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = convolution_plotter_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end