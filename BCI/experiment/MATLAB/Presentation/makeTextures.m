function imageTextures=makeTextures(imageStructs,window)

ind= strcmpi({imageStructs.Type},'Image');

imageTextures.Address={imageStructs(ind).Stimulus};

for count=1:length(imageTextures.Address)
    [image,~,alphaValues]=imread(imageTextures.Address{count});
    image(:,:,4)=alphaValues;
    imageTextures.image{count}=image;
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    imageTextures.tex{count}=Screen('MakeTexture', window, image);
end