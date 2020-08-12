function opCalibrate(cmd)

global opAmpCalib opCalibDialog opChans

if (nargin == 0)
  % Create/show figure for user to edit.
  opCalibDialog = opCalibFig;
  
  % Set the edit box to display opAmpCalib.
  editObj = findobj('Tag', 'countEdit');
  set(editObj, 'String', sprintf('%.6g', opAmpCalib));
  return
end

switch(cmd)
  case 'ok'
    % Read the edit box, store its value in opAmpCalib.
    editObj = findobj(opCalibDialog, 'Tag', 'countEdit');
    cal = str2num(get(editObj, 'String'));			%#ok<ST2NM>
    chg = xor(isnan(cal), isnan(opAmpCalib)) | (cal ~= opAmpCalib);
    if (~isempty(cal) && (cal > 0 || isnan(cal)))	% is user input valid?
      opAmpCalib = abs(cal);
    end
    set(opCalibDialog, 'Visible', 'off')
    if (chg)
      opPositionControls
      if (~isnan(opAmpCalib)), opRefChan(opChans); end
    end
    
  case 'cancel'
    set(opCalibDialog, 'Visible', 'off')
    
end
