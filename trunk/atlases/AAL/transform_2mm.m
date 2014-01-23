clear all
close all

aal=load_nii('aal_original.nii');


aal_mask=find(aal.img>0);
aal_mni=zeros(length(aal_mask),3);
[x y z]=ind2sub(size(aal.img),aal_mask);
aal_mni=[x-91 y-126 z-72];

x_2mm=zeros(size(aal_mni,1),1);
y_2mm=x_2mm;
z_2mm=x_2mm;
aal_2mm=zeros(91,109,91);


for i=1:size(aal_mni,1)
    [x_temp y_temp z_temp]=MNI2space(aal_mni(i,1),aal_mni(i,2),aal_mni(i,3));
    val=aal.img(x(i),y(i),z(i));
    x_2mm(i)=x_temp;
    y_2mm(i)=y_temp;
    z_2mm(i)=z_temp;
    aal_2mm(round(x_temp),round(y_temp),round(z_temp))=val;
end

save_nii(make_nii(aal_2mm,[2 2 2]),'aal_2mm.nii');

% quality check, make sure things on the right cortex are right
