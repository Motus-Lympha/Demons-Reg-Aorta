I = rgb2gray(seqq_2_fake_B);
G = graythresh(I);
I = imbinarize(I,G);
imshow(I)
cc = bwconncomp(I);
labeled = labelmatrix(cc);
RGB_label = label2rgb(labeled,'jet','k','shuffle');
se = strel('disk',8);
RGB_label = imclose(RGB_label,se);
figure
imshow(RGB_label)
imwrite(RGB_label, '/Users/markolchanyi/Desktop/mask_image.jpg');


img = orig_cropped;
[a,b,c] = size(img);

new_mask = zeros(a,b,3);


for i = 1:1:a
    for j = 1:1:b
        if (RGB_label(i,j,1) > 0) || (RGB_label(i,j,2) > 0) || (RGB_label(i,j,3) > 0) 
            img(i,j,1) = RGB_label(i,j,1);
            img(i,j,2) = RGB_label(i,j,2);
            img(i,j,3) = RGB_label(i,j,3);
        end
        
    end 
end

figure 
imshow(img)
imwrite(img, '/Users/markolchanyi/Desktop/overlayed_image.jpg');