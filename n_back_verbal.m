function n_back_verbal(subject_code)
    % there are 25 stimuli representations
    % 10 should be targets 
    % Targets can be in the range from n to 25 - n 
    % Stimuli are selected based on literature 

    %DialogueBox
    prompt = {'Subject Number:','Subject Initials:','Age','Gender (f/m)'}; 
    default = {'0','XX','0','fm'};
    dlgname = 'Setup Info';     
    LineNo = 1;
    
    % disable typing to matlab during experiment
    ListenChar(2);
    
    answer = inputdlg(prompt,dlgname,LineNo,default);
    [subject_code, initials, age, sex] = deal(answer{:});
    screenNumber = 0;                   
    black = BlackIndex(screenNumber);
    white = WhiteIndex(screenNumber);
    gray = round(white/2);
    [wPtr, rect] = Screen('OpenWindow', screenNumber, gray,[]);
    
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
    letters = ['B', 'F', 'K', 'H', 'M', 'Q', 'R', 'X']; % are the 8 letters from literature 

    %define Cross characteristics 
    cLength = 20;
    cWidth = 3;

    %set start and end points of lines 
    cLines = [-cLength, 0 ; cLength, 0 ; 0, -cLength ; 0, cLength];
    cLines = cLines';

    %Open Window
    %[wPtr, rect] =  PsychImaging('OpenWindow',0,[],[0 0 640 480]); 
    Screen('TextFont',wPtr,'Times');
    Screen('TextSize',wPtr, 30);

    % determine screen center 
    screenCenterX = rect(3)/2;
    screenCenterY = rect(4)/2; 

    text_intro_1 = sprintf('Welcome to the Experiment. \n You are about to see letters showing up after each other on the screen. \n If a letters shows up that already showed up %d letters ago,  \n press the space Button! \n \n Press any Button to continue', n);
    text_intro_2 = sprintf('The first %d Trials will be practice Trials \n Press any Button to continue', ptrials);
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
            responses(i,j) = 0;
            %set flip cnt to zero for each representation
            flip_cnt = 0;
            ifi = Screen('GetFlipInterval',wPtr);

            index = randi([1  8],1);
            shown(i,j) = letters(index);
            
            if sendtriggers
                lptwrite(port,triggers(1,i));
                WaitSecs(triggerdur);
                lptwrite(port,0);
            end

            %draw cross in center 
            Screen('DrawLines',wPtr, cLines, cWidth, white,[screenCenterX, screenCenterY]); 
            Screen('Flip',wPtr);
            WaitSecs(0.5);

            if (j>n) 
                memory = shown(i,j-n);
            end
            if(full_vec(j) == 0) 
                while(memory == shown(i,j)) % if a letter is shown which is in memory, get new letter  
                    index = randi([1  8],1);
                    shown(i,j) = letters(index);
                end
            else 
                shown(i,j) = memory;
            end

            %Experiment Letters
            Letter = shown(i,j);

            keyisdown = 0;    
            pressedkey= 0;
            keycode = 0;
            
            if sendtriggers
                lptwrite(port,triggers(2,i));
                WaitSecs(triggerdur);
                lptwrite(port,0);
            end

            while flip_cnt < (0.5/ifi)  
                %Present Letter
                Screen('TextSize',wPtr, 120);
                DrawFormattedText(wPtr, Letter,'center','center', white);
                flip_cnt = flip_cnt + 1;
                Screen('Flip',wPtr);
                %register if key is pressed
                [keyisdown, secs, keycode] = KbCheck(-1); 
                %look if either space key or esc keys are pressed, defined
                %with triggerCodes
                if keyisdown && ismember(find(keycode),triggerCodes)   
                    if find(keycode) == triggerCodes(1) % if space is pressed!
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
            
            Screen('TextSize',wPtr, 30);

            %end
            %if no response has been given at the end of the presentation
            %then response = 0 

                
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
    
    type = 'verbal';   
    save(subject_code, 'type', 'initials','ntrials','ptrials','r','t','n', 'age', 'sex', 'all_vecs','responses','correct_resp_target','false_resp_target', 'type')
    sca;
end

   
