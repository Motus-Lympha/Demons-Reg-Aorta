%{
Reads in images as double from 0 to end_num of size image_size and for 
specific path and extension.
%}

function data = read_images(end_num, digits, image_size, path, extension)
data = zeros(end_num + 1, image_size(1), image_size(2));
for i = 0:end_num
    data(i+1, :,:) = double(imread(strcat(path, num2str(i,...
        strcat('%0',num2str(digits),'d')),extension)));
end
end