classdef myVideoMaker < handle
    % MYVIDEOMAKER A class for capturing and creating videos from MATLAB figures.
    %   This class allows capturing frames from the current figure, storing
    %   them, and rendering a video from the frames. It also supports mirroring
    %   the video in time.
    
    properties
        Frames;            % Cell array to store captured frames
        FrameRate = 30;    % Default framerate
        FileName = 'video'; % Default filename
    end
    
    methods
        function obj = myVideoMaker(fileName, frameRate)
            % MYVIDEOMAKER Constructor for creating a video maker object.
            %   obj = MYVIDEOMAKER() creates an instance with default settings.
            %   obj = MYVIDEOMAKER(fileName) sets the output video filename.
            %   obj = MYVIDEOMAKER(fileName, frameRate) also sets the framerate.
            %
            %   Input arguments:
            %       fileName  - (char) Name of the output video file (default: 'video')
            %       frameRate - (numeric) Framerate of the video (default: 30 fps)
            
            if nargin > 0
                obj.FileName = fileName;
                if nargin > 1
                    obj.FrameRate = frameRate;
                end
            end
            obj.Frames = {};
        end
        
        function capture(obj)
            % CAPTURE Captures the current figure display as a frame.
            %   This function takes a snapshot of the current figure window
            %   and stores it in the Frames property.
            obj.Frames{end+1} = getframe(gcf);
        end
        
        function render(obj)
            % RENDER Creates a video from the captured frames.
            %   The function writes the stored frames to a video file
            %   with the specified filename and framerate.
            
            v = VideoWriter(obj.FileName, 'MPEG-4');
            v.FrameRate = obj.FrameRate;
            open(v);
            for i = 1:length(obj.Frames)
                writeVideo(v, obj.Frames{i});
            end
            close(v);
        end
        
        function mirror(obj)
            % MIRROR Reverses the video frames in time.
            %   This function appends a mirrored version of the frames,
            %   effectively making the video play forward and then in reverse.
            
            N = length(obj.Frames);
            for i = 1 : N-2
                obj.Frames{N+i} = obj.Frames{N-i};
            end
        end
    end
end
