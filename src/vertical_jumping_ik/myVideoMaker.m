classdef myVideoMaker < handle
    properties
        Frames;            % Cell array to store captured frames
        FrameRate = 30;    % Default framerate
        FileName = 'video'; % Default filename
    end
    
    methods
        function obj = myVideoMaker(fileName, frameRate)
            % Constructor
            if nargin > 0
                obj.FileName = fileName;
                if nargin > 1
                    obj.FrameRate = frameRate;
                end
            end
            obj.Frames = {};
        end
        
        function capture(obj)
            % Capture the current figure display
            obj.Frames{end+1} = getframe(gcf);
        end
        
        function render(obj)
            % Render the video
            v = VideoWriter(obj.FileName, 'MPEG-4');
            v.FrameRate = obj.FrameRate;
            open(v);
            for i = 1:length(obj.Frames)
                writeVideo(v, obj.Frames{i});
            end
            close(v);
        end
        
        function mirror(obj)
           % Mirror the video in time
           N = length(obj.Frames);
           for i = 1 : N-2
               obj.Frames{N+i} = obj.Frames{N-i};
           end
        end
    end
end
