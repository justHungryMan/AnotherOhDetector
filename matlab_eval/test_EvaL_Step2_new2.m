clear all
clc

test_results = 'G:\CUImage\20191107_korean_Drama_eval\out3\out3/';
original_labels = 'G:\CUImage\20191107_korean_Drama_eval\Korean_drama_annotations_YOLOv3_2\';

classes = {'person', 'car', 'traffic light',     'backpack', 'handbag', 'tie',    'bottle',   'cup', 'bowl','chair', 'potted plant',    'dining table',         'tv',  'cell phone', 'refrigerator',  'book',         'vase'};

load([test_results '/gt_det']);
load([test_results '/obj_det']);

num_imgs = size(obj_fn, 2);

tp_cell = cell(1,num_imgs);
fp_cell = cell(1,num_imgs);
gt_thr = 0.25;
ov_val = cell(1,num_imgs);
for i=1:num_imgs
    gt_labels_ = gt_labels{i};
    gt_bboxes_ = gt_bboxes{i};
    num_gt_obj = length(gt_labels_);
    gt_detected = zeros(1,num_gt_obj);
   
    labels = obj_labels{i};
    bboxes = obj_bboxes{i};

    num_obj = length(labels);
    tp = zeros(1,num_obj);
    fp = zeros(1,num_obj);
    ov_val_this = zeros(1,num_obj);
    for j=1:num_obj
        bb = bboxes(:,j);        
        ovmax = -inf;
        kmax = -1;
        %a = 1;
        for k=1:num_gt_obj
            
            if labels(j) ~= gt_labels_(k)
               continue;
            end
            if gt_detected(k) > 0
                continue;
            end
            bbgt = gt_bboxes_(:,k);
            
                
            bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
            iw=bi(3)-bi(1)+1;
            ih=bi(4)-bi(2)+1;
            
            
            if iw>0 & ih>0                
                % compute overlap as area of intersection / area of union
                ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                   (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
                   iw*ih;
                ov=iw*ih/ua;
                                
                % makes sure that this object is detected according
                % to its individual threshold
                if ov >= gt_thr && ov > ovmax
                    ovmax=ov;
                    kmax=k;                    
                end
            end
        end
        if kmax > 0
            tp(j) = 1;
            gt_detected(kmax) = 1;
            ov_val_this(j) = ovmax;
        else
            fp(j) = 1;
        end
    end

    % put back into global vector
    tp_cell{i} = tp;
    fp_cell{i} = fp;

    for k=1:num_gt_obj
        label = gt_labels_(k);
    end
ov_val{i} = ov_val_this;
end


fprintf('eval_detection :: computing ap\n');
tp_all = [tp_cell{:}];
fp_all = [fp_cell{:}];
obj_labels = [obj_labels{:}];
confs = [obj_confs{:}];

[confs ind] = sort(confs,'descend');
tp_all = tp_all(ind);
fp_all = fp_all(ind);
obj_labels = obj_labels(ind);
num_classes = 17;
for c=1:num_classes
    % compute precision/recall
    tp = cumsum(tp_all(obj_labels==(c)));
    fp = cumsum(fp_all(obj_labels==(c)));
    recall{c}=(tp/num_pos_per_class((c)))';
    precision{c}=(tp./(fp+tp))';
    ap(c) =VOCap(recall{c},precision{c});
    disp([classes{c} ' : ' num2str(ap(c)*100) ' %']);
%     figure; plot(recall{c}, precision{c})
%     title(['Class : ' synsets(c).name ',  AP : ' num2str(ap(c))])
%     xlabel('Recall')
%     ylabel('Precision')
%     axis([0 1 0 1])
%     saveas(gcf,[out_dir2 synsets(c).name '_4.png'])
%     close all
%  save([out_dir2 synsets(c).name '_stats_fusion_ACC_BN.mat'],'tp', 'fp');
end

mAP = mean(ap)
