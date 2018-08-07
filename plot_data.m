function plot_data(subject_code)

    %load(num2str(subject_code),'.mat') 

    %just some plots of correct and incorrect response to targets
    dim = size(correct_resp_target);
    for i = 1:dim(2)
        sum_correct(i) = sum(correct_resp_target(:,i));
        sum_falseCorrect(i) = sum(false_resp_target(:,i));
    end
    plot(sum_correct)
    plot(sum_falseCorrect)


end
