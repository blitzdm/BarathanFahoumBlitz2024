

%% Load up the data
%NOTE:
%have all the burst channels visible, named PD, LG, etc with cursors set to
%start where there is a PD burst but NO LG, IC, DG, LPG bursts and to end
%similar condition;
%export as matlab file, set to visible channels, time range=cursors
%do not time shift, that way we know where in the file things are happening
%and can check the analysis
%make sure to check "use source channel name in variable names"


%Currently set to count gastric bursts where the gastric neuron burst was
%on at the start of a pyloric cycle


clear all; close all; clc; %clears workspace, command window,
%load('G:\Shared drives\Blitz Lab\Barathan_Gnanabharathi\Experiments\Burst Channel\ALL Just SIFamide\Phase_CP') %loads the struct with the data in it
load('G:\Shared drives\Blitz Lab\Barathan_Gnanabharathi\Experiments\Burst Channel\ALL Just SIFamide\Phase_CP') %loads the struct with the data in it

label = [];
for i_exp = 1: length(Phase_CP.exps)
    for i_chan = 1 : length (Phase_CP.channels)
        lbl = append(Phase_CP.exps(i_exp), Phase_CP.channels(i_chan)); %put label names together into one name (each neuron)
        label = [label ; lbl]; %create array with list of channel names (exp plus _neuron)
        load(Phase_CP.exps(i_exp))
        %need to set all initial values to 0 somehow.
    end
end

for i_exp = 1: length(Phase_CP.exps) %loop through all experiments
    data=[]; % this clears the struct
    data=load(Phase_CP.exps{i_exp}); %this loads one exp with all its neuron fields into this struct

    %TO GET 0 (no burst) as first position of gastric neurons starting
    %just a tiny bit before the first PD burst

    PDch = append(Phase_CP.exps(i_exp), "_PD"); %name the PD channel
    PDfirst=(data.(PDch).times(1)-0.02); %subtract tiny bit off the time of first PD burst
    numevents = (length(data.(PDch).level)-2); %shouldn't need to subtract 2 if export correctly from spike2
    for i_fix = 1 : length(Phase_CP.channels)
        Channame = append(Phase_CP.exps(i_exp), (Phase_CP.channels{i_fix})); %name the neuron channel
        is=exist(Channame);
        if is==1
            data.(Channame).times = [PDfirst; data.(Channame).times(1:end)]; %inserts a row and put value of PDfirst then the rest of the array
            data.(Channame).level = [0; data.(Channame).level(1:end)]; %inserts a row with 0 for no burst to start with
            %Burstname = append("Burst",(Phase_CP.channels{i_fix})) %name the place to indicate if a burst or not during each CP
            %x=[];
            %Phase_CP.(Phase_CP.exps{i_exp}).(Burstname)=x;
        end
   
    end

    %sf=1/data.(label{1}).resolution;  %sampling frequency--don't think
    %i need these 2 lines for burst channels
    %data.(label{1}).data=0:data.(label{1}).resolution:data.(label{1}).length/sf-1/sf;
    %PDch = append(Phase_CP.exps(i_exp), "_PD");
    %data.(PDch).level = double(data.(PDch).level);
    numevents = (length(data.(PDch).level)-2); %shouldn't need to subtract 2 if export correctly from spike2

    listnum=1;  % this is index for the rows of the cycle period data
    i_PD=1;

    %counters for each exp, for # of cycle pds dropped into LGburst or
    %DG burst column etc
    countLG=1; countDG=1; countIC=1; countLPG=1; countLG_IC=1; countLPG_DG=1; countSIFbaseline=1; countOther=1; countLG_DG=1; countLG_LPG=1; countIC_LPG=1; countIC_DG=1; countLG_IC_DG=1; countLG_LPG_IC=1; countIC_DG_LPG=1; countLG_DG_LPG=1; countLG_IC_DG_LPG=1;


    %first find right cycle and calculate PD CP
    while i_PD < numevents
        CPnum=find(data.(PDch).level(i_PD:end)==1,1); % this returns how many more rows until the next 1 (including the current row)
        CPnum=(i_PD + CPnum - 1); %add the additonal rows to the current row number
        PDstart=data.(PDch).times(CPnum);
        i_PD=CPnum + 1;
        CPnum=find(data.(PDch).level(i_PD:end)==1,1); % this returns how many more rows until the next 1
        CPnum=(i_PD + CPnum - 1); %add the additonal rows to the current row number
        PDstop=data.(PDch).times(CPnum);
        Phase_CP.(Phase_CP.exps{i_exp}).PD_time(listnum,1)= PDstart;
        Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1)= (PDstop-PDstart); %start a list of cycle periods

        %CHECK FOR gastric BURSTs [find out if each individual gastric neuron was
        %active during a pyloric cycle]

        %CHECK FOR LG BURST
        LGch = append(Phase_CP.exps(i_exp), "_LG"); %name the LG channel
        num=find(data.(LGch).times<=PDstart,1,'last');%the last time lower than the current PDstart
        numc=find(data.(LGch).times<=PDstop,1,'last');%the last time lower than the current PDstop
        numb=find(data.(LGch).times>PDstart,1,'first'); %THE FIRST THING HIGHER AFTER pdstart

        %SEPT 30: Replace numb and add numbc
        % plus DELETE THESE THREE LINES PLUS "END" BELOW, PLUS
        %FIX the IF STATEMENT FOR BURST DETECTION OF ALL NEURONS

        %if num == 1 %there's no bursts before here so =0 BARAT
        %   Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1)=0;
        %else
        if data.(LGch).level(num)==1 | data.(LGch).level(numc)==1 | (data.(LGch).level(numb)==1 & data.(LGch).times(numb)<PDstop)
            Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1)=1;
        else
            Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1)=0;
        end
        % end

        %CHECK FOR DG BURST

        DGch = append(Phase_CP.exps(i_exp), "_DG"); %name the DG channel
        is=exist(DGch);
        if is==1
            num=find(data.(DGch).times<=PDstart,1,'last'); %the last time lower than the current PDstart
            numc=find(data.(DGch).times<=PDstop,1,'last');%the last time lower than the current PDstop
            numb=find(data.(DGch).times>PDstart,1,'first'); %THE FIRST THING HIGHER AFTER pdstart

            % if num == 1 %there's no bursts before here so =0
            %     Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1)=0;
            % else
            % if data.(DGch).level(num)==1 | data.(DGch).level(numb)==1
            if data.(DGch).level(num)==1 | data.(DGch).level(numc)==1 | (data.(DGch).level(numb)==1 & data.(DGch).times(numb)<PDstop)
                Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1)=1;
            else
                Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1)=0;
            end
            %end
        end

        %CHECK FOR IC BURST

        ICch = append(Phase_CP.exps(i_exp), "_IC"); %name the IC channel
        num=find(data.(ICch).times<=PDstart,1,'last'); %the last time lower than the current PDstart
        numc=find(data.(ICch).times<=PDstop,1,'last');%the last time lower than the current PDstop
        numb=find(data.(ICch).times>PDstart,1,'first'); %THE FIRST THING HIGHER AFTER pdstart

        % if num == 1 %there's no bursts before here so =0
        %     Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1)=0;
        % else
        if data.(ICch).level(num)==1 | data.(ICch).level(numc)==1 | (data.(ICch).level(numb)==1 & data.(ICch).times(numb)<PDstop)
            Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1)=1;
        else
            Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1)=0;
        end
        % end

        %CHECK FOR LPG BURST

        LPGch = append(Phase_CP.exps(i_exp), "_LPG"); %name the LG channel
        is=exist(LPGch);
        if is==1
            num=find(data.(LPGch).times<=PDstart,1,'last'); %the last time lower than the current PDstart
            numc=find(data.(LPGch).times<=PDstop,1,'last');%the last time lower than the current PDstop
            numb=find(data.(LPGch).times>PDstart,1,'first'); %THE FIRST THING HIGHER AFTER pdstart

            %if num == 1 %there's not bursts before here so =0
            %     Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1)=[0];
            % else
            if data.(LPGch).level(num)==1 | data.(LPGch).level(numc)==1 | (data.(LPGch).level(numb)==1 & data.(LPGch).times(numb)<PDstop)
                Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1)=[1];
            else
                Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1)=[0];
            end
            %end
        end

        %how many gastric neurons were active during this PD CP?
        a=Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1);
        is=exist(DGch);
        if is==0
            b=0;
        else
            b=Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1);
        end
        c=Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1);
        d=Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1);
        Phase_CP.(Phase_CP.exps{i_exp}).Burstsum(listnum,1) = (a+b+c+d); %sum=# of gastric neurons with burst during pyloric cycle

        %Which column does this Cycle period go into?  ie, which gastric
        %neuron is the only one active during this cycle period?
        check=0;
        if Phase_CP.(Phase_CP.exps{i_exp}).Burstsum(listnum,1) == 1 %is the sum 1? if so go check which  neuron in sub-loops

            %is it LG only?
            if Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1) == 1  %is it LG?
                Phase_CP.(Phase_CP.exps{i_exp}).LGphase(countLG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot in LG list!
                Phase_CP.(Phase_CP.exps{i_exp}).PD_CPtime(countLG,1) = PDstart;
                countLG=countLG + 1;
                check=1;
            end

            %is it DG only?
            is=exist(DGch);
            if is==1
                if Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1) == 1 %is it DG?
                    Phase_CP.(Phase_CP.exps{i_exp}).DGphase(countDG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                    countDG=countDG + 1;
                    check=1;
                end
            end

            %is it IC only?
            if Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1) == 1 %is it IC?
                Phase_CP.(Phase_CP.exps{i_exp}).ICphase(countIC,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                countIC=countIC + 1;
                check=1;
            end

            %is it LPG only?
            if Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1) == 1 %is it LPG?
                Phase_CP.(Phase_CP.exps{i_exp}).LPGphase(countLPG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                countLPG=countLPG + 1;
                check=1;
            end
        end

  %Were 2 neurons active during this pyloric cycle?
        if Phase_CP.(Phase_CP.exps{i_exp}).Burstsum(listnum,1) == 2 %were 2 neurons active? if so, go to subloops to check which combos

            %is it LG and IC?
            if Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1) == 1  %is it LG and IC?
                Phase_CP.(Phase_CP.exps{i_exp}).LG_ICphase(countLG_IC,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                Phase_CP.(Phase_CP.exps{i_exp}).LG_ICphasePDtime(countLG_IC,1)=PDstart;
                countLG_IC=countLG_IC + 1;
                check=1;
            end

            %is it LG and LPG?
            if Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1) == 1  %is it LG and LPG?
                Phase_CP.(Phase_CP.exps{i_exp}).LG_LPGphase(countLG_LPG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                Phase_CP.(Phase_CP.exps{i_exp}).LG_LPGphasePDtime(countLG_LPG,1)=PDstart;
                countLG_LPG=countLG_LPG + 1;
                check=1;
            end

            %is it LG and DG?
            is=exist(DGch); %check for DG existence since it's not always there
            if is==1
                if Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1) == 1  %is it LG and DG?
                    Phase_CP.(Phase_CP.exps{i_exp}).LG_DGphase(countLG_DG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                    Phase_CP.(Phase_CP.exps{i_exp}).LG_DGphasePDtime(countLG_DG,1)=PDstart;
                    countLG_DG=countLG_DG + 1;
                    check=1;
                end
            end

            %is it IC and LPG?
            if Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1) == 1  %is it IC and LPG?
                Phase_CP.(Phase_CP.exps{i_exp}).IC_LPGphase(countIC_LPG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                Phase_CP.(Phase_CP.exps{i_exp}).IC_LPGphasePDtime(countIC_LPG,1)=PDstart;
                countIC_LPG=countIC_LPG + 1;
                check=1;
            end

            %is it IC and DG?
            is=exist(DGch); %check for DG existence since it's not always there
            if is==1
                if Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1) == 1  %is it IC and DG?
                    Phase_CP.(Phase_CP.exps{i_exp}).IC_DGphase(countIC_DG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                    Phase_CP.(Phase_CP.exps{i_exp}).IC_DGphasePDtime(countIC_DG,1)=PDstart;
                    countIC_DG=countIC_DG + 1;
                    check=1;
                end
            end

            %is it DG and LPG?
            is=exist(DGch); %check for DG existence since it's not always there
            if is==1
                if Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1) == 1 %is it DG and LPG?
                    Phase_CP.(Phase_CP.exps{i_exp}).LPG_DGphase(countLPG_DG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                    Phase_CP.(Phase_CP.exps{i_exp}).LPG_DGphasePDtime(countLPG_DG,1)=PDstart;
                    countLPG_DG=countLPG_DG + 1;
                    check=1;
                end
            end
        end %end of checking for 2 neuron combinations

  %Were 3 neurons active during this pyloric cycle?
        if Phase_CP.(Phase_CP.exps{i_exp}).Burstsum(listnum,1) == 3 %were 3 neurons active? if so, go to subloops to check which combos

            %is it IC and DG and LPG?
            is=exist(DGch);%check for DG existence since it's not always there
            if is==1
                if Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1) == 1  %is it IC and DG and LPG?
                    Phase_CP.(Phase_CP.exps{i_exp}).IC_DG_LPGphase(countIC_DG_LPG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                    Phase_CP.(Phase_CP.exps{i_exp}).IC_DG_LPGphasePDtime(countIC_DG_LPG,1)=PDstart;
                    countIC_DG_LPG=countIC_DG_LPG + 1;
                    check=1;
                end
            end

            %is it LG, IC and DG?
            is=exist(DGch); %check for DG existence since it's not always there
            if is==1
                if Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1) == 1  %is it LG, IC and DG?
                    Phase_CP.(Phase_CP.exps{i_exp}).LG_IC_DGphase(countLG_IC_DG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                    Phase_CP.(Phase_CP.exps{i_exp}).LG_IC_DGphasePDtime(countLG_IC_DG,1)=PDstart;
                    countLG_IC_DG=countLG_IC_DG + 1;
                    check=1;
                end
            end

            %is it LG and DG and LPG?
            is=exist(DGch); %check for DG existence since it's not always there
            if is==1
                if Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).DGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1) == 1 %is it LG and DG and LPG?
                    Phase_CP.(Phase_CP.exps{i_exp}).LG_DG_LPGphase(countLG_DG_LPG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                    Phase_CP.(Phase_CP.exps{i_exp}).LG_DG_LPGphasePDtime(countLG_DG_LPG,1)=PDstart;
                    countLG_DG_LPG=countLG_DG_LPG + 1;
                    check=1;
                end
            end

            %is it LG, IC and LPG?
            if Phase_CP.(Phase_CP.exps{i_exp}).LGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).LPGburst(listnum,1) == 1 & Phase_CP.(Phase_CP.exps{i_exp}).ICburst(listnum,1) == 1 %is it LG, IC and LPG?
                Phase_CP.(Phase_CP.exps{i_exp}).LG_LPG_ICphase(countLG_LPG_IC,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
                Phase_CP.(Phase_CP.exps{i_exp}).LG_LPG_ICphasePDtime(countLG_LPG_IC,1)=PDstart;
                countLG_LPG_IC=countLG_LPG_IC + 1;
                check=1;
            end
        end
       
 %Were 4 neurons active during this pyloric cycle?
        if Phase_CP.(Phase_CP.exps{i_exp}).Burstsum(listnum,1) == 4 %were 4 neurons active? 
            Phase_CP.(Phase_CP.exps{i_exp}).LG_IC_DG_LPGphase(countLG_IC_DG_LPG,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
            Phase_CP.(Phase_CP.exps{i_exp}).LG_IC_DG_LPGphasePDtime(countLG_IC_DG_LPG,1)=PDstart;
            countLG_IC_DG_LPG=countLG_IC_DG_LPG + 1;
            check=1;
        end

  %Were no neurons (LG, IC, DG, LPG) active?
        if Phase_CP.(Phase_CP.exps{i_exp}).Burstsum(listnum,1) == 0 %were 0 gastric neurons active? if so, this is SIFbaseline
            Phase_CP.(Phase_CP.exps{i_exp}).SIFbaselinephase(countSIFbaseline,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);%put this into next open spot!
            Phase_CP.(Phase_CP.exps{i_exp}).SIFbaselinephasePDtime(countSIFbaseline,1)=PDstart;
            countSIFbaseline=countSIFbaseline + 1;
            check=1;
        end
        
  %Was this pyloric cycle not categorized yet? if so = other
        if check==0
            Phase_CP.(Phase_CP.exps{i_exp}).Otherphase(countOther,1) = Phase_CP.(Phase_CP.exps{i_exp}).PD_CP(listnum,1);
            Phase_CP.(Phase_CP.exps{i_exp}).OtherphasePDtime(countOther,1)=PDstart;
            countOther=countOther+1;
        end

        listnum=listnum+1;

    end  %end of categorizing a pyloric cycle, go to next one

    %Check to see if there were any CPs under each GMR neuron, if so, add
    %to the overall list for all exps
    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LGphase');
    if is==1
        Phase_CP.LGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LGphase);
        Phase_CP.Avg_CP_LG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LGphase);

    else Phase_CP.Avg_CP_LG(i_exp) = NaN;

    end
    
    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'DGphase');
    if is==1
        Phase_CP.DGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).DGphase);
        Phase_CP.Avg_CP_DG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).DGphase);
        Phase_CP.CV_CP_DG(i_exp)= (std(Phase_CP.(Phase_CP.exps{i_exp}).DGphase)/mean(Phase_CP.(Phase_CP.exps{i_exp}).DGphase));
    else Phase_CP.Avg_CP_DG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LPGphase');
    if is==1
        Phase_CP.LPGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LPGphase);
        Phase_CP.Avg_CP_LPG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LPGphase);
        Phase_CP.CV_CP_LPG(i_exp)= (std(Phase_CP.(Phase_CP.exps{i_exp}).LPGphase)/mean(Phase_CP.(Phase_CP.exps{i_exp}).LPGphase));
    else Phase_CP.Avg_CP_LPG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'ICphase');
    if is==1
        Phase_CP.ICphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).ICphase);
        Phase_CP.Avg_CP_IC(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).ICphase);
    else Phase_CP.Avg_CP_IC(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LG_ICphase');
    if is==1
        Phase_CP.LG_ICphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LG_ICphase);
        Phase_CP.Avg_CP_LG_IC(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_ICphase);
        Phase_CP.CV_CP_LG_IC(i_exp)= (std(Phase_CP.(Phase_CP.exps{i_exp}).LG_ICphase)/mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_ICphase));
    else Phase_CP.Avg_CP_LG_IC(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LG_DGphase');
    if is==1
        Phase_CP.LG_DGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LG_DGphase);
        Phase_CP.Avg_CP_LG_DG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_DGphase);
        Phase_CP.CV_CP_LG_DG(i_exp)= (std(Phase_CP.(Phase_CP.exps{i_exp}).LG_DGphase)/mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_DGphase));
    else Phase_CP.Avg_CP_LG_DG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LG_LPGphase');
    if is==1
        Phase_CP.LG_LPGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LG_LPGphase);
        Phase_CP.Avg_CP_LG_LPG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_LPGphase);
        Phase_CP.CV_CP_LG_LPG(i_exp)= (std(Phase_CP.(Phase_CP.exps{i_exp}).LG_LPGphase)/mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_LPGphase));
    else Phase_CP.Avg_CP_LG_LPG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'IC_DGphase');
    if is==1
        Phase_CP.IC_DGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).IC_DGphase);
        Phase_CP.Avg_CP_IC_DG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).IC_DGphase);
        Phase_CP.CV_CP_IC_DG(i_exp)= (std(Phase_CP.(Phase_CP.exps{i_exp}).IC_DGphase)/mean(Phase_CP.(Phase_CP.exps{i_exp}).IC_DGphase));
    else Phase_CP.Avg_CP_IC_DG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'IC_LPGphase');
    if is==1
        Phase_CP.IC_LPGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).IC_LPGphase);
        Phase_CP.Avg_CP_IC_LPG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).IC_LPGphase);
        Phase_CP.CV_CP_IC_LPG(i_exp)= (std(Phase_CP.(Phase_CP.exps{i_exp}).IC_LPGphase)/mean(Phase_CP.(Phase_CP.exps{i_exp}).IC_LPGphase));
    else Phase_CP.Avg_CP_IC_LPG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LPG_DGphase');
    if is==1
        Phase_CP.LPG_DGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LPG_DGphase);
        Phase_CP.Avg_CP_LPG_DG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LPG_DGphase);
    else Phase_CP.Avg_CP_LPG_DG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LG_DG_ICphase');
    if is==1
        Phase_CP.LG_DG_ICphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LG_DG_ICphase);
        Phase_CP.Avg_CP_LG_DG_IC(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_DG_ICphase);
    else Phase_CP.Avg_CP_LG_DG_IC(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LG_LPG_ICphase');
    if is==1
        Phase_CP.LG_LPG_ICphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LG_LPG_ICphase);
        Phase_CP.Avg_CP_LG_LPG_IC(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_LPG_ICphase);
    else Phase_CP.Avg_CP_LG_LPG_IC(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'IC_DG_LPGphase');
    if is==1
        Phase_CP.IC_DG_LPGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).IC_DG_LPGphase);
        Phase_CP.Avg_CP_IC_DG_LPG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).IC_DG_LPGphase);
    else Phase_CP.Avg_CP_IC_DG_LPG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LG_DG_LPGphase');
    if is==1
        Phase_CP.LG_DG_LPGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LG_DG_LPGphase);
        Phase_CP.Avg_CP_LG_DG_LPG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_DG_LPGphase);
    else Phase_CP.Avg_CP_LG_DG_LPG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LG_IC_DGphase');
    if is==1
        Phase_CP.LG_IC_DGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LG_IC_DGphase);
        Phase_CP.Avg_CP_LG_IC_DG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_IC_DGphase);
    else Phase_CP.Avg_CP_LG_IC_DG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'LG_IC_DG_LPGphase');
    if is==1
        Phase_CP.LG_IC_DG_LPGphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).LG_IC_DG_LPGphase);
        Phase_CP.Avg_CP_LG_IC_DG_LPG(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).LG_IC_DG_LPGphase);
    else Phase_CP.Avg_CP_LG_IC_DG_LPG(i_exp) = NaN;
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'SIFbaselinephase');
    if is==1
        Phase_CP.SIFbaselinePhase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).SIFbaselinephase);
        Phase_CP.Avg_CP_SIFbaseline(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).SIFbaselinephase);
        Phase_CP.CV_CP_SIFbaseline(i_exp)= (std(Phase_CP.(Phase_CP.exps{i_exp}).SIFbaselinephase)/mean(Phase_CP.(Phase_CP.exps{i_exp}).SIFbaselinephase));
    end

    is=isfield(Phase_CP.(Phase_CP.exps{i_exp}),'Otherphase');
    if is==1
        Phase_CP.Otherphase_CP(i_exp)=length(Phase_CP.(Phase_CP.exps{i_exp}).Otherphase);
        Phase_CP.Avg_CP_Other(i_exp)=mean(Phase_CP.(Phase_CP.exps{i_exp}).Otherphase);
    else Phase_CP.Avg_CP_Other(i_exp) = NaN;
    end
end

figure
set(gcf,'name','ALL SIFamide')
x=1;
for i_neurons = 1:length(Phase_CP.Phases)
    Neuronch = append("Avg_CP", Phase_CP.Phases(i_neurons));
    Phase_CP.(Neuronch) = Phase_CP.(Neuronch)(~isnan(Phase_CP.(Neuronch)));
    y=((mean(Phase_CP.(Neuronch))/1.3848162528473)); %fix it to remove nan from the code

    BurstFreq = 1/y;

    CV = std( Phase_CP.(Neuronch))/y;
    AVGch = append("TotalAVG_SE", Phase_CP.Phases(i_neurons));
    Phase_CP.(AVGch)(1)=y;
    Phase_CP.(AVGch)(1,2)=BurstFreq;
    stderror= append("SE_CP", Phase_CP.Phases(i_neurons));
    stderror= std( Phase_CP.(Neuronch)) / sqrt( length(Phase_CP.(Neuronch)));
    length(Phase_CP.(Neuronch));
    Phase_CP.(AVGch)(2,1)=stderror;
    Phase_CP.(AVGch)(1,3)= CV;

    bar(x,y);
    hold on
    %er = errorbar(x,y,stderror,stderror);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
    %for i_dots= 1 : length(Phase_CP.(Neuronch))
      % hold on
    %  y=(Phase_CP.(Neuronch)(i_dots));
     % plot(x,y,'o',MarkerFaceColor='black');
    %end

    x=x+1;
end
xticks([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17]);
labels=(Phase_CP.Phases(1:end));
xticklabels(labels);
ylabel("Cycle Period (s)")
ylim([0 2])

save("Phase_CP_ALLSIF_data.mat", "Phase_CP");