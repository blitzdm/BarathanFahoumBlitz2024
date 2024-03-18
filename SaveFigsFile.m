%% Saves a SINGLE Figure
% This function is a useful add for other scripts/functions only when the 
% function you are using outputs one figure.
% Make sure to have the folder you want to save your figures to open in the
% path above (i.e. N:\Shared drives\Blitz Lab... etc..

%IMPORTANT NOTE: your input struct MUST have a field called filename, in
%which that field contains the filename as a string.

% By: Savanna-Rae Fahoum 08.15.2023


function SaveFigsFile(struct) % name of the struct you are working from

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for i_fig = 1:length(FigList)
    FigHandle = FigList(i_fig);
    FigName   = num2str(get(FigHandle, 'Number')); 
    filename = append(struct.filename, ".pdf");
    set(0, 'CurrentFigure', FigHandle);
    exportgraphics(figure(i_fig), filename, 'ContentType', 'vector')
end

end
