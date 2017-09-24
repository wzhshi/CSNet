%------------------------------------------------------------------------------------------------------
%This is the test demo for "Deep networks for compressed image sensing." (ICME2017)
%Author: Wuzhen Shi
%Email: wzhshi@hit.edu.cn
%School of Computer Science of Technology, Harbin Institute of Technology
%-------------------------------------------------------------------------------------------------------

%BibTex:
% @inproceedings{Shi2017Deep,
%   title={Deep networks for compressed image sensing},
%   author={Shi, Wuzhen and Jiang, Feng and Zhang, Shengping and Zhao, Debin},
%   booktitle={IEEE International Conference on Multimedia and Expo},
%   pages={877-882},
%   year={2017},
% }

%Usage:
%set different samplingRate (0.1 to 0.5) to obtain the same results as we
%report in the ICME2017 paper.

samplingRate = 0.1;

run '.\matconvnet-1.0-beta23\matlab\vl_setupnn.m'

addpath('.\utilities');

folderTest  = '.\testData\Set5';

showResult  = 1;


load(['.\model\sampling' num2str(samplingRate) '.mat']);

%%% read images
ext         =  {'*.jpg','*.png','*.bmp'};
filePaths   =  [];
for i = 1 : length(ext)
    filePaths = cat(1,filePaths, dir(fullfile(folderTest,ext{i})));
end

PSNRs_CSNet = zeros(1,length(filePaths));
SSIMs_CSNet = zeros(1,length(filePaths));

for i = 1:length(filePaths)
    
    %%% read images
    image = imread(fullfile(folderTest,filePaths(i).name));
    [~,nameCur,extCur] = fileparts(filePaths(i).name);
     if size(image,3) == 3
        image = modcrop(image,32); 
        image = rgb2ycbcr(image); 
        image = image(:,:,1);
     end
    
    label = im2single(image);
    input =label;

    res    = vl_simplenn(net,input,[],[],'conserveMemory',true,'mode','test');
    output = res(end).x;    
    
    %%% calculate PSNR and SSIM
    [PSNRCur_CSNet, SSIMCur_CSNet] = Cal_PSNRSSIM(im2uint8(label),im2uint8(output),0,0);
    if showResult
        imshow(cat(2,im2uint8(label),im2uint8(output)));
        title([filePaths(i).name,'    ',num2str(PSNRCur_CSNet,'%2.2f'),'dB','    ',num2str(SSIMCur_CSNet,'%2.4f')])
        drawnow;
    end

    PSNRs_CSNet(i) = PSNRCur_CSNet;
    SSIMs_CSNet(i) = SSIMCur_CSNet;
end
 disp([mean(PSNRs_CSNet),mean(SSIMs_CSNet)]);