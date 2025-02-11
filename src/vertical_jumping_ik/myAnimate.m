function myAnimate(animationFunction, animationSampleNumber, animationSamplingTime, videoMaker, videoFrameRate)
    if nargin < 4
        videoMaker = [];
        videoFrameRate = 0;
        videoSamplePeriod = inf;
    else
        videoSamplePeriod = round(1 ./ videoFrameRate / animationSamplingTime);
    end
    tmr = timer();
    tmr.StartFcn = @(thisTimer, thisEvent) fprintf("\nStarting animation...\n");
    tmr.TimerFcn = @(thisTimer, thisEvent) timerCallbackFunction(thisTimer, thisEvent, animationFunction, videoMaker, videoSamplePeriod);
    tmr.StopFcn = @(thisTimer, thisEvent) timerKillFunction(thisTimer, thisEvent, videoMaker);
    tmr.Period = animationSamplingTime;
    tmr.TasksToExecute = animationSampleNumber;
    tmr.ExecutionMode = 'fixedRate';

    tmr.start();
end

function timerCallbackFunction(thisTimer, ~, animationFunction, videoMaker, videoSamplePeriod)
    ii = thisTimer.TasksExecuted;
    animationFunction(ii);
    if mod(ii, videoSamplePeriod) == 0
        if ~isempty(videoMaker)
            fprintf("%d\n", ii);
            videoMaker.capture()
        end
    end
end

function timerKillFunction(thisTimer, ~, videoMaker)
    fprintf("Ending animation.\n");
    if ~isempty(videoMaker)
        videoMaker.render()
    end
    thisTimer.delete();
end