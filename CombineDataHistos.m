function CombineDataHistos(structname, savename) %, nameit)
%need to pre=load the relevant struct ex: load('structname_ALLSIF_data.mat')
%here are the lines for the command window
%CombineDataHistos(Phase_CP, "Phase_CP_ALLSIF_data.mat")
%CombineDataHistos(Phase_CP_kill, "Phase_CP_LPGkill_data.mat")


%GO THROUGH EXPS AND NORMALIZE DATA FOR EACH NEURON TO SIFBASELINE for that
%EXP

for i_exp = 1:length(structname.exps)

    AVG_None=mean(structname.(structname.exps{i_exp}).(structname.histonames{1})); %avg the cycles with no gastric neurons active for each exp

    for i_neuron=1:length(structname.histonames) %go through list of neurons
        i_neuron;
        is=isfield(structname.(structname.exps{i_exp}),(structname.histonames{i_neuron})); %make sure there were (for ex:) LGphase PR cycles in this exp

        if is==1
            normphase=append((structname.histonames{i_neuron}), "Norm");
            expname=structname.exps(i_exp);
            x = structname.(expname).(structname.histonames{i_neuron})(1:end); %put the data into temp variable
            x = x/AVG_None; %normalize the data
            structname.(structname.exps{i_exp}).(normphase)= x; %put normalized data into new field
            TempNormCell{1, i_neuron} = structname.(expname).(normphase); %temporary storage cell
        else
        end
    end

    %NOW COMPILE ALL THE NORMALIZED CYCLE PERIODS INTO A SINGLE SET FOR EACH
    %EXP
    structname.(expname).AllNorm =  [];
    normphase=append((structname.histonames{1}), "Norm");
    % structname.(expname).AllNorm =  structname.(expname).(structname.histonames{2}); %get the first one into the cumulative column
    structname.(expname).AllNorm =  structname.(expname).(normphase);
    for i_neuron=2:length(structname.histonames)
        normphase=append((structname.histonames{i_neuron}), "Norm");
        is=isfield(structname.(structname.exps{i_exp}),(normphase)); %if this phase exists then we'll concatenate it into the all column
        if is==1
            structname.(expname).AllNorm = [structname.(expname).AllNorm; structname.(expname).(normphase)]; %vertical concatentation format
            %A = [A;C{k}]; reminder of the format for vertical concatenate
        end
    end


end

structname.AllExpsNorm = []; %compiling all CPs for all EXPS
expname=structname.exps(1);
structname.AllExpsNorm = [structname.(expname).AllNorm];
for i_exp = 2:length(structname.exps)
    expname=structname.exps(i_exp);
    structname.AllExpsNorm = [structname.AllExpsNorm; structname.(expname).AllNorm];
end

%NOW HISOGRAMS HERE

figure

%bedge = 0:1:1; %sets bins from 0: (in xx ms) :to x sec 
Histo =   histogram(structname.AllExpsNorm, 107, 'FaceColor', [0.8 0.5 0.8], 'Edgecolor', [0.8 0.5 0.8]); %creates histogram from that vector with those bin params
%fixed above histogram at 107 bins instead of using "bedge" parameters so
%it matches the LPGkill histogram binsize
structname.AllExpsHisto = Histo;
MaxBin = max(structname.AllExpsHisto.BinCounts);
structname.AllExpsHisto.BinCounts = structname.AllExpsHisto.BinCounts/MaxBin;
title(savename);
axis('tight');
xlim([0 3]);
ylabel("Count");
xlabel("Cycle Period Normalized to SIFbaselinePhase");
fname = (savename);
save savename structname;
end
