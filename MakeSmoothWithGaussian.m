function Rsmth = MakeSmoothWithGaussian( r, sigma ) %to get millisecond divide by 10
   x = -10000:10000;
   w = exp(-(x/sigma).^2/2)/sqrt(2*pi)/sigma;
   for i = 1 : size(r, 1)
        z = conv(r(i,:), w);
        z=z(ceil(length(w)/2):end-floor(length(w)/2));
        r(i,:) = z;
   end
   Rsmth = r;  
   
   %To check and nice plot
   %plot((0:0.1:99.9), r_temp(1,1:1000), 0:0.1:99.9, Rsmth(1,1:1000)* (max(r_temp) / max(Rsmth)), 'g');
end
