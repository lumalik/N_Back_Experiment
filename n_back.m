function n_back(subject_code,type)
    %this function will call a verbal or visual n back task
    %for plotting there is an extra function 

    if type == "visual"
        n_back_visual(subject_code)
    end

    if type == "verbal"
        n_back_verbal(subject_code)
    end

end

 