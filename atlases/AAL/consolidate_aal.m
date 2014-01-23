clear all
close all

load aal_labels;
img=load_nii('aal_2mm.nii');
load ../cor_sub_cer.mat % variable cor_sub_cer



% remove subcortex
for i=1:length(aal_subcortex)
    img.img(find(img.img==aal_subcortex(i)))=0;
end

% remove cerebellum
for i=1:length(aal_cerebellum)
    img.img(find(img.img==aal_cerebellum(i)))=0;
end


% left
left_mask=zeros(91,109,91);
left_mask(1:45,:,:)=1;
cor_mask=zeros(91,109,91);
cor_mask(find(cor_sub_cer==1))=1;
left_mask=cor_mask.*left_mask;
better_left=img.img.*left_mask;






ids=find(left_mask>0);
bad=[];
for i=1:length(ids)
    val=better_left(ids(i));
    if(val>0 && mod(val,2)==0)
        bad=[bad; ids(i)]; % marking wrong left right
        better_left(ids(i))=-1;
    end
    if(val==0)  % marking missing stuff
        bad=[bad; ids(i)];
        better_left(ids(i))=-1;        
    end
end

% fixing the wrongs
map=find(better_left<0);
while(length(map>0))
    map=find(better_left<0);
    for v=1:length(map)
        [xv yv zv]=ind2sub(size(better_left),map(v));
        % check the neighbours
        nei=[];
        for x=-1:1;
            for y=-1:1;
                for z=-1:1;
                    if(x==0 && y==0 && z==0)
                        continue;
                    end
                    nei=[nei;better_left(xv+x,yv+y,zv+z)];
                end
            end
        end
        temp=unique(nei);
        stats=histc(nei,temp);
        if(max(temp)>0)
            % find the winner
            candidates=find(temp>0);
            cand_count=stats(candidates);
            M=find(max(cand_count)==stats(candidates));
            winner=temp(candidates(M(1)));
            better_left(xv,yv,zv)=winner;

        end
    end
end








% right
right_mask=zeros(91,109,91);
right_mask(46:end,:,:)=1;

cor_mask=zeros(91,109,91);
cor_mask(find(cor_sub_cer==1))=1;
right_mask=cor_mask.*right_mask;
better_right=img.img.*right_mask;

ids=find(right_mask>0);
bad=[];
for i=1:length(ids)
    val=better_right(ids(i));
    if(val>0 && mod(val,2)==1)
        bad=[bad; ids(i)]; % marking wrong left right
        better_right(ids(i))=-1;
    end
    if(val==0)  % marking missing stuff
        bad=[bad; ids(i)];
        better_right(ids(i))=-1;        
    end
end

% fixing the wrongs
map=find(better_right<0);
while(length(map>0))
    map=find(better_right<0);
    for v=1:length(map)
        [xv yv zv]=ind2sub(size(better_right),map(v));
        % check the neighbours
        nei=[];
        for x=-1:1;
            for y=-1:1;
                for z=-1:1;
                    if(x==0 && y==0 && z==0)
                        continue;
                    end
                    nei=[nei;better_right(xv+x,yv+y,zv+z)];
                end
            end
        end
        temp=unique(nei);
        stats=histc(nei,temp);
        if(max(temp)>0)
            % find the winner
            candidates=find(temp>0);
            cand_count=stats(candidates);
            M=find(max(cand_count)==stats(candidates));
            winner=temp(candidates(M(1)));
            better_right(xv,yv,zv)=winner;

        end
    end
end

temp=better_right+better_left;

save_nii(make_nii(temp,[2 2 2]),'aal_cortex_consolidated.nii');
