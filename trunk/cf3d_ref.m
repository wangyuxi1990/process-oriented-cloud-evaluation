clear all

%load lat-lon- pression grid boxes
presm=load('/homedata/dkonsta/modele/grilles_lmdz/pression_cfmip_mil');
ncid=netcdf('/bdd/CFMIP/GOCCP/MapLowMidHigh/grid_2x2xL40/2007/day/MapLowMidHigh330m_200701_day_CFMIP2_sat_2.1.nc')
lat=ncid{'latitude'}(:,:); 
lon=ncid{'longitude'}(:); 


maskoc=load('/homedata/dkonsta/modele/grilles_lmdz/land_ocean_mask2_2d.asc')';


% read variable Cloud Fraction 
chemin='/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2007/day/daily/'
list=dir('/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2007/day/daily/MapLowMidHigh330m*')
for ifile=1:length(list)
   ifile
   ncid=netcdf([chemin list(ifile).name])
   cftot(ifile,:,:)=ncid{'cltcalipso'}(:,:); 
   close(ncid) 
end 

chemin='/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2008/day/daily/'
list=dir('/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2008/day/daily/MapLowMidHigh330m*')
for ifile=1:length(list)
   ifile
   ncid=netcdf([chemin list(ifile).name])
   cftot(ifile+362,:,:)=ncid{'cltcalipso'}(:,:); 
   close(ncid) 
end 
 
  
cftot(cftot<-100)=NaN;



% read variable Cloud Fraction 3D
chemin='/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2007/day/daily/'
list=dir('/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2007/day/daily/3D_CloudFraction330m*')
for ifile=1:length(list)
   ifile  
   ncid=netcdf([chemin list(ifile).name])
   cf3D(ifile,:,:,:,:)=ncid{'clcalipso'}(:,:,:,:);
   close(ncid)
end

chemin='/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2008/day/daily/'
list=dir('/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2008/day/daily/3D_CloudFraction330m*')
for ifile=1:length(list)
   ifile  
   ncid=netcdf([chemin list(ifile).name])
   cf3D(ifile+362,:,:,:,:)=ncid{'clcalipso'}(:,:,:,:);
   close(ncid)
end

cf3D(cf3D<-100)=NaN;



% read variable Cloud Reflectance 


chemin='/bdd/CFMIP/GOCCP/Dimitra/CRef/daily/'
list=dir('/bdd/CFMIP/GOCCP/Dimitra/CRef/daily/cloud_*_CFMIP.nc')
for ifile=1:length(list)
   ifile
   ncid=netcdf([chemin list(ifile).name])
   reflecloud(ifile,:,:)=ncid{'CRef_par'}(:,:);
   close(ncid)
end 

reflecloud(reflecloud<-100)=NaN;




 % exclude the land 
     
for ilon=1:length(lon)
    for ilat=1:length(lat)
        if maskoc(ilon,ilat)>0.5 %| lat(ilat) < -30 | lat(ilat) > 30
            reflecloud(:,ilon,ilat)=NaN;
        end 
    end
end
    


% calculate the mean vertical profile of Cloud Fraction for each bin of Cloud Reflectance 

refbin=[0:0.02:1.02];

for iref=1:length(refbin)-1 
    iref
    for ialt=1:40
     cf(iref,ialt)=0;
     is(iref,ialt)=0;
        for ilon=1:length(lon)
             for ilat=31:60                 
                 for iday=1:705
                     if (lat(ilat)<30&lat(ilat)>-30) 
                     if (refbin(iref)<reflecloud(iday,ilon,ilat)&reflecloud(iday,ilon,ilat)<=refbin(iref+1)&cf3D(iday,ialt,ilat,ilon)>-50)
                            cf(iref,ialt)=cf(iref,ialt)+cf3D(iday,ialt,ilat,ilon);
                            is(iref,ialt)=is(iref,ialt)+1;
                     end     
                     end
                   end
             end
        end
        cf(iref,ialt)=cf(iref,ialt)/is(iref,ialt);
    end
end


% plot the relation between Cloud Reflectance and the mean vertical profile of Cloud Fraction 

a=[0.75 0 1; 0.5 0 1; 0 0 1; 0 0.5 1; 0 1 1; 0 1 0.5; 0 1 0; 0.5 1 0; 1 1 0; 1 0.5 0; 1 0 0; 1 0 0.5];
 
 

figure
pcolor(refbin(1:end-1),presm,cf')
shading flat
axis([0 0.75 108 977])
hold on
plot([0 1],[680 680],'k-')
plot([0 1],[440 440],'k-')
caxis([0 0.4])
colormap(a)
axis ij
colorbar
ay1 = gca;
set(ay1,'YColor','k')
xlabel ('REFLECTANCE')
ay2 = axes('Position',get(ay1,'Position'),...
           'XAxisLocation','top',...
           'Color','none',...
           'XColor','k');
set(gca,'xtick',[0:8])
set(gca,'xticklabel',{'0','1.46','3.41','5.50','8.11','11.42','16.52','24.92','40.46'})          
axis([0 7.5 108 977])
axis ij
xlabel('OPTICAL THICKNESS')
ylabel('PRESSURE (hPa)')











