clear all
clc

test_results = 'G:\CUImage\20191107_korean_Drama_eval\out3\out3/';
original_labels = 'G:\CUImage\20191107_korean_Drama_eval\Korean_drama_annotations_YOLOv3_2\';
%original_labels = './labels_544_2007/';

coco = 1;
test_results_dir = dir([test_results '\*.txt']);

offsetw = 0;
offseth = 0;
new_img = 1;
ii = 1;

obj_fn = cell(1,length(test_results_dir));
obj_confs = cell(1,length(test_results_dir));
obj_labels = cell(1,length(test_results_dir));
obj_bboxes = cell(1,length(test_results_dir));

map = [0 1; 2 2; 9 3; 24 4; 26 5; 27 6; 39 7; 41 8; 45 9; 56 10; 58 11; 60 12; 62 13; 67 14; 72 15; 73 16; 75 17];

for i=1:length(test_results_dir)
    filename = test_results_dir(i).name;
    %filename = [filename(1:end-4) '.txt'];
    fid = fopen([test_results filename], 'r');
    
    tline = fgetl(fid);
    TestData(ii).imageFilename = filename;
    %TestData(ii).labels = 0;
    scale = 1; flag = 0;
    j=1;
    while ischar(tline)
        flag = 1;
        TestData(ii).imageFilename = filename;
        coord = strsplit(tline, ' ');   
%         if(map(str2num(coord{1})+1,2) > -1 || coco == 0)
        %TestData(ii).labels = str2num(coord{1});
        if(coco)
            TestData(ii).labels = (find(map(:,1) == str2num(coord{1})));
        else
            TestData(ii).labels = str2num(coord{1}) + 1;
        end
         TestData(ii).prob = 1; %str2num(coord{6});
 
            left_top_x = str2num(coord{2}) * scale;         left_top_y = str2num(coord{3}) * scale;
            right_bottom_x = str2num(coord{4}) * scale;     right_bottom_y = str2num(coord{5}) * scale; %w h
          
            a(1) = left_top_x; %a(2) = right_top_x;
            a(2) = right_bottom_x + a(1); %w
            b(1) = left_top_y; %b(2) = right_top_y;
            b(2) = right_bottom_y + b(1); %h

            newline = [((a(1))-offsetw) (b(1)-offseth) ((a(2))+offsetw) ((b(2))+offseth)]; % x y w h 
            TestData(ii).objectBoundingBoxes = newline;
            ii = ii + 1; 
            
             confs(j) = 1 ;%str2num(coord{6});
            if(coco)
                labels(j) = (find(map(:,1) == str2num(coord{1})));
            else
                labels(j) = str2num(coord{1}) + 1;
            end
            bbox(:,j) = newline';
            j = j + 1;
            
%         end
            
            tline = fgetl(fid);       
          
    end
    if(flag == 0)
        ii = ii + 1;
    end
    if(j>1)
        obj_confs{i} = confs;
        obj_bboxes{i} = bbox;
        obj_labels{i} = labels;
        
    end
    obj_fn{i} = filename;
    fclose('all');
    
    
    clear confs labels bbox filename
    
end

save([test_results 'TestData.mat'],'TestData');
save([test_results 'obj_det'], 'obj_confs', 'obj_bboxes', 'obj_labels', 'obj_fn' );
 fclose('all');

new_img = 1;
ii = 1;

obj_fn = cell(1,length(test_results_dir));
gt_labels = cell(1,length(test_results_dir));
gt_bboxes = cell(1,length(test_results_dir));
Img = original_labels;
% outImgs = './gt_detecions/';
% mkdir(outImgs);
% load('voc_names');
num_pos_per_class = zeros(1, length(map));
for i=1:length(test_results_dir)
    filename = test_results_dir(i).name;
    filename = [filename(1:end-4) '.txt'];
    I = imread([Img '\' filename(1:end-4) '.jpg']);
    [hi, wi, ~] = size(I);
    fid = fopen([original_labels '\' filename], 'r');
    
    j=1;
    try
    tline = fgetl(fid);
    GTData(ii).imageFilename = filename;
%     GTData(ii).labels = tline(1);
    scale = 1; flag = 0;
    
    while ischar(tline)
        flag = 1;
        GTData(ii).imageFilename = filename;
                         
        coord = strsplit(tline, ' ');
        GTData(ii).labels = num2str(str2num(coord{1}) + 1);
        x_ = str2num(coord{2}) * scale;         y_ = str2num(coord{3}) * scale;
        %right_top_x = str2num(coord{3}) * scale;        right_top_y = str2num(coord{4}) * scale;
        w_ = str2num(coord{4}) * scale;     h_ = str2num(coord{5}) * scale; %w h
        %left_bottom_x = str2num(coord{7}) * scale;      left_bottom_y = str2num(coord{8}) * scale;

        x1 = (2*x_*wi - w_*wi)/2; x2 = (2*x_*wi - x1); 
        y1 = (2*y_*hi - h_*hi)/2; y2 = (2*y_*hi - y1); 

        newline = [x1 y1 x2 y2]; % x y w h 
        if(0)
            I = insertObjectAnnotation(I,'rectangle', [x1 y1 x2-x1 y2-y1], voc_names{str2num(coord{1})+1}, 'Color', 'green', 'TextBoxOpacity',0.4, 'TextColor','black', 'FontSize',18);
        end
        GTData(ii).objectBoundingBoxes = newline;
        ii = ii + 1;
        labels(j) = (find(map(:,1) == str2num(coord{1}))); %str2num(coord{1})+1;
        bbox(:,j) = newline';
        num_pos_per_class(find(map(:,1) == str2num(coord{1}))) = num_pos_per_class(find(map(:,1) == str2num(coord{1}))) + 1;
        j = j + 1;
        
        tline = fgetl(fid);
        
    %     disp(newline);
          
    end
    
    if(flag == 0)
        ii = ii + 1;
    end
    fclose(fid);
    catch
    end
    if(j>1)
        gt_bboxes{i} = bbox;
        gt_labels{i} = labels;
        gt_fn{i} = filename;
    end
%     imwrite(I, [outImgs '\' filename(1:end-4) '.jpg']);
    clear labels bbox filename
end

save([test_results 'GTData.mat'],'GTData');
save([test_results 'gt_det'], 'gt_bboxes', 'gt_labels', 'gt_fn', 'num_pos_per_class' );