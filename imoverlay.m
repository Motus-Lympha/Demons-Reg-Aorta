


img = orig;
mask = Montage_ano;
mask2 = mask_goblets;
%mask(:,:,1) = 0;
mask3 = nuclei_mask_NEW_new;

[a,b,c] = size(img);

for i = 1:1:a
    for j = 1:1:b
        if mask(i,j) > 0    
            tmp1 = img(i,j,1);
            tmp2 = img(i,j,3);
            img(i,j,1) = 0;
            img(i,j,3) = 0;
            img(i,j,2) = img(i,j,2)*1.4;
        end
        if (mask(i,j) > 0) && (mask2(i,j) > 0)  
            img(i,j,1) = 0;
            img(i,j,2) = 0;
            img(i,j,3) = tmp2*1.2;
        end
        if (mask(i,j) <= 0) && (mask3(i,j) > 0)  
            tmp = img(i,j,1);
            img(i,j,3) = img(i,j,1)*0.01;
            img(i,j,2) = 0;
            img(i,j,1) = tmp*1.2;
        end
        
    end 
end

%img(mask>0) = 0;
image(img)
set(gca,'ydir','reverse');
imwrite(img,'/Users/markolchanyi/Desktop/newimage_with_inflammation.png');
image(img)
