function n_back_visual(subject_code)
    % there are 25 stimuli representations
    % 10 should be targets 
    % Targets can be in the range from n to 25 - n 
    % Stimuli are selected based on literature
    %DialogueBox
    prompt = {'Subject Number:','Subject Initials:','Age','Gender (f/m)'}; 
    default = {'0','XX','0','fm'};
    dlgname = 'Setup Info';     
    LineNo = 1;  

    answer = inputdlg(prompt,dlgname,LineNo,default);
    [num, initials, age, sex] = deal(answer{:});
    screenNumber = 0;  
    black = BlackIndex(screenNumber);
    white = WhiteIndex(screenNumber);
    gray = round(white/2);
    [wPtr, rect] = Screen('OpenWindow', screenNumber, gray,[]);
 
    % disable typing to matlab during experiment
    %ListenChar(2);
   
    
    %find the lowest screen dimension, scale rect to this
    [ii,ii] = sort(rect);
    minRect = rect(ii([end-1]));
    %minRect = min(rect); 
    
    % screen center 
    screenCenterX = round(rect(3)/2);
    screenCenterY = round(rect(4)/2);
    
    % Positions 
    dim = 1;

    [x, y] = meshgrid(-dim:dim, -dim:dim);                   

    % size
    stimPix = (1/3)*minRect; % pixels in each dimension (x and y)
    
    % Calculating Stimulus Size and Cue in Degrees of Visual Angle


    yPix_stim = stimPix; % stimulus height (in pixels) from code
    xPix_stim = stimPix; % stimulus width (in pixels) from code

    yPix_cue = stimPix; % stimulus height (in pixels) from code
    xPix_cue = stimPix; % stimulus width (in pixels) from code

    y_res = rect(4); % y-axis pixels from: [wPtr, rect]=Screen('OpenWindow',ScreenNumber);
    x_res = rect(3); % x-axis pixels from: [wPtr, rect]=Screen('OpenWindow',ScreenNumber);

    y_size   = 17,6; % measured (in cm) monitor
    x_size   = 33,7; % measured (in cm) monitor
    viewdist = 57; % measured (in cm)
                                                          
    ppd_y = (viewdist*(tan(pi/180)))*(y_res/y_size); % pixels-per-degree
    ppd_x = (viewdist*(tan(pi/180)))*(x_res/x_size); % pixels-per-degree

    yDeg_stim = yPix_stim / ppd_y; % stimulus height in degrees of visual angle
    xDeg_stim = xPix_stim / ppd_x; % stimulus width in degrees of visual angle

    yDeg_cue = yPix_cue / ppd_y; % cue height in degrees of visual angle
    xDeg_cue = xPix_cue / ppd_x; % cue width in degrees of visual angle

    % setup stimulus sizes in degrees of visual angle so size remains constant
    % across different systems (you need monitor height and width, resolution 
    % and viewing distance).

    stimSize_xPix = xDeg_stim * ppd_x;
    stimSize_yPix = yDeg_stim * ppd_y;

    cueSize_xPix = xDeg_cue * ppd_x;
    cueSize_yPix = yDeg_cue * ppd_y;


    % number of stims
    nStim = 9;

    % get center coordinates of each rectangle in grid
    xPos = x .* stimPix + screenCenterX;
    yPos = y .* stimPix + screenCenterY;

    % Make the destination rectangles for all the stims in the grid
    baseRect = [0 0 stimPix stimPix];
   
    for i = 1:nStim
        allRects(:, i) = CenterRectOnPointd(baseRect, xPos(i), yPos(i));
    end    
    
    %looks like this
    % 1 4 7
    % 2 5 8  
    % 3 6 9 
    %allRects(:,number)

    % basic variables
    ptrials = 5; %number of practice trials 
    etrials = 20; % number of trials in experiment 
    ntrials = ptrials + etrials; % total number of trials in experiment 
    r = 30; % number of representations 
    n = 2; % n in n back task 
    t = 10; % number of targets 

    % provide a consistent mapping of keyCodes to key names on all operating systems.
    KbName('UnifyKeyNames');

    % define response keys and trigger Codes 
    responseKeys = {'space','ESCAPE'};
    triggerCodes = [KbName('space'),KbName('ESCAPE')];

    % this will keep a string in memory 
    memory = "";
    fields = ['1', '2', '3', '4', '5', '6', '7', '8', '9']; % are the 9 fields for our stimuli to appear

    %define Cross characteristics 
    cLength = 30; 
    cWidth = 3;

    %set start and end points of lines 
    cLines = [-cLength, 0 ; cLength, 0 ; 0, -cLength ; 0, cLength];
    cLines = cLines';

    %Open Window
    %[wPtr, rect] =  PsychImaging('OpenWindow',0,[],[0 0 640 480]); 
    Screen('TextFont',wPtr,'Times');
    Screen('TextSize',wPtr, 30); 

    text_intro_1 = sprintf('Welcome to the Experiment. \n You are about to see squares showing up at different locations on the screen. \n If a square shows up in the same location as %d squares ago,  \n press the space Button! \n \n Press any Button to continue', n);
    text_intro_2 = sprintf('The first %d Trials will be practice Trials', ptrials);
    end_text = 'Thank you for participating in this experiment.';    
    vec_start = zeros(1, n); % first n positions are always not targets 
    
    % EEG 
    triggers(1,1:ntrials) = 1; %fixation cross
    triggers(2,:) = 2; %stimulus
    sendtriggers = 0;
    port = 888;
    triggerdur = 0.001;
    
    %set up responses matrix 
    responses = zeros(r,ntrials);
    correct_resp_target = zeros(r,ntrials);
    false_resp_target = zeros(r,ntrials);

    for i=1:ntrials
        if i == 1 
            DrawFormattedText(wPtr, text_intro_1,'center','center', white);
            Screen('Flip',wPtr);
            WaitSecs(0.5);
            KbWait(); 
             

            DrawFormattedText(wPtr, text_intro_2,'center','center', white);
            Screen('Flip',wPtr);
               WaitSecs(0.5);
            KbWait(); 
        end

        vec = zeros(1, r-n); %positions n +1 to r can be either targets or non targets 
        vec(randperm(numel(vec), t)) = 1; % this gives us a fixed number of ones at random positions 
        full_vec = horzcat(vec_start,vec); %join the two vectors to get a vector of length r 

        all_vecs(:,i) = full_vec;
        
        %update break text 
        text_between_trials = sprintf('This was Trial %d of %d Trials \n Feel free to make a break. \n Press any Button when you are ready to continue.', i, ntrials);

        %fDur = round(0.500/ifi); % numbers are in seconds
        %startTime = GetSecs();
        keyisdown = 0;    
        pressedkey= 0;
        keycode = 0;

        for j=1:r
            
            %set flip cnt to zero for each representation
            flip_cnt = 0;
            ifi = Screen('GetFlipInterval',wPtr);

            index = randi([1  8],1);
            shown(i,j) = fields(index);
                    %Send EEG Trigger for fixation cross
            if sendtriggers
                lptwrite(port,triggers(1,i));
                WaitSecs(triggerdur);
                lptwrite(port,0);
            end
            %draw fix cross in center 
            Screen('DrawLines',wPtr, cLines, cWidth, white,[screenCenterX, screenCenterY]); 
            Screen('Flip',wPtr);
            WaitSecs(0.5);

            if (j>n) 
                memory = shown(i,j-n);
            end
            if(full_vec(j) == 0) 
                while(memory == shown(i,j)) % if a letter is shown which is in memory, get new letter  
                    index = randi([1  8],1);
                    shown(i,j) = fields(index);
                end
            else 
                shown(i,j) = memory;
            end

            %Experiment Rectangle
            field = allRects(:,str2num(shown(i,j)));

            keyisdown = 0;    
            pressedkey= 0;
            keycode = 0;
            
            if sendtriggers
                lptwrite(port,triggers(2,i));
                WaitSecs(triggerdur);
                lptwrite(port,0);
            end
            
            while flip_cnt < (0.5/ifi)  
                %Present Rectangle 
                Screen('FillRect',wPtr,white,field);
                flip_cnt = flip_cnt + 1;
                Screen('Flip',wPtr);
                %register if key is pressed
                [keyisdown, secs, keycode] = KbCheck(-1); 
                %look if either space key or esc keys are pressed, defined
                %with triggerCodes
                if keyisdown && ismember(find(keycode),triggerCodes)   
                    if find(keycode) == triggerCodes(1) % if space is pressed, exit!
                             responses(j,i) = 1; 
                             if all_vecs(j,i) == 1 
                                 correct_resp_target(j,i) = 1; 
                             end
                             if all_vecs(j,i) == 0
                                 false_resp_target(j,i) = 1; 
                             end
                    end
                    if find(keycode) == triggerCodes(2) % if ESC is pressed, exit!
                             sca;
                             clear  Screen;
                             ListenChar();                % reenable keyboard input to matlab
                             disp('Error: ESCAPE break'); % display this text
                             return;                      % exit
                    end
                end  
            end
                
        end
        
         
        if i<=ptrials 
            text_ptrials = ['In this trial you got \n ', num2str(sum(correct_resp_target(:,i))) ,' out of ', num2str(t),' correct. \n There were \n ', num2str(sum(false_resp_target(:,i))),' false alarms '];
            DrawFormattedText(wPtr, text_ptrials,'center','center', white);
            Screen('Flip',wPtr);
            KbWait(); 
        end

        if i==ntrials
            DrawFormattedText(wPtr, end_text,'center','center', white);
            Screen('Flip',wPtr);
            KbWait();
            break
        end 
        DrawFormattedText(wPtr, text_between_trials,'center','center', white);
        Screen('Flip',wPtr);
        WaitSecs(0.5);
        KbWait();

    end
              
    type = 'visual'; 
    save(subject_code, 'type', 'initials','ntrials','ptrials','r','t','n', 'age', 'sex', 'all_vecs','responses','correct_resp_target','false_resp_target', 'type')
    sca;
    
end
    



