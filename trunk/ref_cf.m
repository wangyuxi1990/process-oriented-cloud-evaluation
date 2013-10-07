clear all

ncid=netcdf('/bdd/CFMIP/GOCCP/MapLowMidHigh/grid_2x2xL40/2007/day/MapLowMidHigh330m_200704_day_CFMIP2_sat_2.1.nc')
lat=ncid{'latitude'}(:,:); 
lon=ncid{'longitude'}(:); 


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

 maskoc=load('/homedata/dkonsta/modele/grilles_lmdz/land_ocean_mask2_2d.asc')';
     
for ilon=1:length(lon)
    for ilat=1:length(lat)
        if maskoc(ilon,ilat)>0.5 %| lat(ilat) < -30 | lat(ilat) > 30
            reflecloud(:,ilon,ilat)=NaN;
        end 
    end
end
    


% read variable Cloud Fraction 
chemin='/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2007/day/daily/'
list=dir('/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2007/day/daily/MapLowMidHigh330m*')
for ifile=1:length(list)
   ifile
   ncid=netcdf([chemin list(ifile).name])
   cftot(ifile,:,:)=ncid{'cltcalipso'}(:,:); 
   cflow(ifile,:,:)=ncid{'cllcalipso'}(:,:); 
   cfhigh(ifile,:,:)=ncid{'clhcalipso'}(:,:);
   close(ncid) 
end 

chemin='/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2008/day/daily/'
list=dir('/bdd/CFMIP/GOCCP/Dimitra/grid_2x2xL40/2008/day/daily/MapLowMidHigh330m*')
for ifile=1:length(list)
   ifile
   ncid=netcdf([chemin list(ifile).name])
   cftot(ifile+362,:,:)=ncid{'cltcalipso'}(:,:); 
   cflow(ifile+362,:,:)=ncid{'cllcalipso'}(:,:); 
   cfhigh(ifile+362,:,:)=ncid{'clhcalipso'}(:,:);
   close(ncid) 
end 

cftot(cftot<-100)=NaN;
cflow(cflow<-100)=NaN;
cfhigh(cfhigh<-100)=NaN;
     
for ilon=1:length(lon)
    for ilat=1:length(lat)
        if maskoc(ilon,ilat)>0.5 %| lat(ilat) < -30 | lat(ilat) > 30
            cftot(:,ilat,ilon)=NaN;
            cflow(:,ilat,ilon)=NaN;
            cfhigh(:,ilat,ilon)=NaN;
        end 
    end
end
    


 
     
% count number of points included in the bins of Cloud Fraction and Cloud Reflectance 

cfbin=[0:0.03:1.06];
refbin=[0:0.03:1.06];

for iref=1:length(refbin)-1 
      iref 
    for icf=1:length(cfbin)-1 
     is(iref,icf)=0;
     islow(iref,icf)=0;
     ishigh(iref,icf)=0;
        for ilon=1:length(lon)
               for ilat=31:60        %tropiques   for ilat=1:length(lat)
                 for iday=1:705  %30
                     if (lat(ilat)<30&lat(ilat)>-30) 
                     %if (lat(ilat)>30 | lat(ilat)<-30)  %hautes lat
                     %if ((lat(ilat) > -5 & lat(ilat) < 20) & (lon(ilon) > 70 & lon(ilon) < 150))  %tropical western pacifique
                     %if ((lat(ilat) > 15 & lat(ilat) < 35) & (lon(ilon) > -140 & lon(ilon) < -110))  %californian stratus region
                     %if ((lat(ilat) > 30 & lat(ilat) < 60) & (lon(ilon) > 160 | lon(ilon) < -140))  %pacifique nord
                     if (refbin(iref)<reflecloud(iday,ilon,ilat)&reflecloud(iday,ilon,ilat)<=refbin(iref+1))... 
                            & (cfbin(icf)<=cftot(iday,ilat,ilon)&cftot(iday,ilat,ilon)<cfbin(icf+1))
                            is(iref,icf)=is(iref,icf)+1;
                         if (cflow(iday,ilat,ilon)>0.9*cftot(iday,ilat,ilon))
                             islow(iref,icf)=islow(iref,icf)+1;
                         end
                         if (cfhigh(iday,ilat,ilon)>0.9*cftot(iday,ilat,ilon))
                             ishigh(iref,icf)=ishigh(iref,icf)+1;
                         end     
                     end
                   end
                end
             end
        end
    end
end

%normalise in relation to the total number of points 
nomis=sum(is,1);
nomis=sum(nomis);
is=is/nomis;
nomislow=sum(islow,1);
nomislow=sum(nomislow);
islow=islow/nomislow;
nomishigh=sum(ishigh,1);
nomishigh=sum(nomishigh);
ishigh=ishigh/nomishigh;


% plot the relation between Cloud Reflectance and Cloud Fraction 


a=[0.75 0 1; 0.5 0 1; 0 0 1; 0 0.5 1; 0 1 1; 0 1 0.5; 0 1 0; 0.5 1 0; 1 1 0; 1 0.5 0; 1 0 0; 1 0 0.5];

figure
pcolor(cfbin(1:end-1),refbin(1:end-1),is)
shading flat
axis([0 1 0 1])
caxis([0 0.008])
colormap(a)
colorbar
ylabel ('CLOUD REFLECTANCE')
xlabel('CLOUD FRACTION')
%title('LOW CLOUDS')

   
% plot geographical distribution of points with CF>90% for low clouds 
   

        for ilon=1:length(lon)
               for ilat= 1:length(lat)       %tropiques   for ilat=1:length(lat)
               num_low(ilat,ilon)=0;
               num_low_max(ilat,ilon)=0;
                 for iday=1:705  %30
                     if (lat(ilat)<30&lat(ilat)>-30) 
                         if (cflow(iday,ilat,ilon)>0.9*cftot(iday,ilat,ilon)& cftot(iday,ilat,ilon)>0.9)
                             num_low_max(ilat,ilon)=num_low_max(ilat,ilon)+1;
                         end   
                     end
                   end
                end
             end
  



lon(1)=-180;
lon(end)=180;

figure
m_proj('hammer-aitoff','clongitude',-150,'lat',[-30 30])
m_pcolor(lon,lat,num_low_max)
hold on
m_pcolor(lon-360,lat,num_low_max)
shading flat
colormap(a)
m_grid('linestyle','none','tickdir','out','linewidth',1);
m_coast('color','k')
%caxis([0 0.7])
title('NUMBER OF POINTS WHERE CF>0.9 FOR LOW CLOUDS MAINLY')
colorbar
