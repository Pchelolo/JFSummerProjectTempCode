function a = STE_analisys( spike_struct, move_struct )

   [ spike_times, spike_electrodes, move_times, move_acc, move_gyr ] = AlignTheData( spike_struct, move_struct );
   [ R, t ] = getFiringRates(spike_times, spike_electrodes);
   for i=0:7
      for j=1:16
         subplot(16,8,i*8 + j);
         plot(xcorr(R(i*8+j),move_acc(1:1400)));
      end
   end
   
end

