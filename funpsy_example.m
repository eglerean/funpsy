clear all
close all

%%
% In this example it is assumed that you succesfully ran FUNPSY with your data and have computed IPS, SBPS, ISBPS.
% The example shows how to load and plot data for two ROIs based on the AAL atlas

% load the psess file
load funpsy_out/test_funpsy.mat

% pick two rois you want to visualize
roi1=79;
roi2=85;

if(roi1==roi2)
    error('pick two different rois')
end

if(roi1>roi2)
    roi1temp=roi2;
    roi2=roi1;
    roi1=roi1temp;
end

% load the ROIs time series (phases) for each participant
rr=[roi1 roi2];
for r=1:2
    rID=rr(r);
    for s=1:psess.Nsubj
       load([psess.roidata{s} '/' num2str(rID)]); %variable roits
       allrois(:,s,r)=angle(roits);
    end
    
end


% load IPS result 4D matrix and compute a ROI-averaged IPS time series 
load(psess.results.ips); % variable ips
ipsts=[];
for r=1:2
    rID=rr(r);
    map=psess.rois(rID).map;
    temp=0;
    for i=1:size(map,1)
        temp=temp+squeeze(ips(map(i,1),map(i,2),map(i,3),:));
    end
    temp=temp/size(map,1);
    ipsts=[ipsts temp];
end



% visualize IPS timeseries for the two ROIs
figure(1)
subplot(3,1,1)
plot(ipsts(:,1),'b');
hold on
plot(ipsts(:,2),'r');


% load and plot SBPS dynamic connectivity roi1 roi2
load([psess.results.sbps '/' num2str(roi1)]); %variable sbpsts
sbps_r1r2=sbpsts(:,roi2-roi1);
plot(sbps_r1r2,'k')
TMAX=300;
% load and plot ISBPS dynamic connectivity roi1 roi2
load([psess.results.isbps '/' num2str(roi1)]); %variable sbpsts
isbps_r1r2=isbpsts(:,roi2-roi1);
plot(isbps_r1r2,'Color',[.2 .5 .2])
title('IPS, SBPS and SBPS time series for the two selected ROIs')
xlabel('Time [TR]')
ylabel('Synchronization')
legend([{[psess.rois(roi1).label ' IPS'],[psess.rois(roi2).label ' IPS'],'SBPS','ISBPS'}],'Interpreter','none' )
axis([0 TMAX -.2 1])

subplot(3,1,2)
imagesc(allrois(:,:,1)',[-pi pi])
colormap(hsv(11))
h=colorbar('East')
set(h,'Ticks',[-pi -pi/2 0 pi/2 pi])
set(h,'Ticklabels',{'-\pi','-\pi/2', '0', '\pi/2', '\pi'})
title(['Individuals'' phase time series' psess.rois(roi1).label],'Interpreter','none')

xlabel('Time [TR]')
ylabel('Subject ID')
axis([0 TMAX .5 16.5])

subplot(3,1,3)
imagesc(allrois(:,:,2)',[-pi pi])
colormap(hsv(11))
h=colorbar('East')
set(h,'Ticks',[-pi -pi/2 0 pi/2 pi])
set(h,'Ticklabels',{'-\pi','-\pi/2', '0', '\pi/2', '\pi'})

title(['Individuals'' phase time series' psess.rois(roi2).label],'Interpreter','none')
xlabel('Time [TR]')
ylabel('Subject ID')
axis([0 TMAX .5 16.5])

set(gcf,'units','normalized','outerposition',[0 0 1 1]/2)

saveas(gcf,'DemoResults.png')

