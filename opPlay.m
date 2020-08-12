function [factor,var] = opPlay(cmd, avifilename)
% opPlay('button')
%    Play the selection (if there is one) or the screen (if not).
%    This is called when the user clicks on the Play button.
%
% opPlay('all')
%    Play the whole sound.
%
% opPlay('disptext')
%    Set the button text according to whether there's a selection or not.
%
% opPlay('setratetext')
%    Set the popup (opPlayRateMenu) to the set of possible play rate factors.
%
% opPlay('setrate')
%    Set the rate to the given value.  This is the menu callback.  If the
%    choice is 'Other', display a dialog box for entering a new playback rate.
%
% [factor,purefactor] = opPlay('getinterp')
%    Return the current playback rate factor.  If it's negative,
%    it means the machine has variable playback rate hardware or software 
%    at a lower level, and that -factor is multiplicative factor to pass down.
%    Also return the playback rate purefactor.  This is different from
%    getinterp, as that uses the machine's defaultsrate while this is 'pure'.
%
% opPlay('othercallback')
%    Internal function for handling the uiInput() callback.
%
% opPlay('movie')
%    Ask user for a file name to store a playback movie in, and store it.
%
% opPlay('movie', avifilename)
%    Internal callback: Make the movie and store it in avifilename.
%
% opPlay('stopplay')
%    Stop the current playback and fix the on-screen button text.

global opc opNSamp opSRate opT0 opT1 opSelT0 opSelT1 spAudioPlayer
global opPlayBut opFig opTMax opPlayRateMenu opPlayRate opPlayOthers 
global uiInputButton uiInput1 opPlayCorrection opEpsDir opPlayTimer
global opFps; opFps = 24;		% animation frame rate

if (~exist('opPlayOthers','var')), opPlayOthers = []; end
if (nargin < 2), avifilename = ''; end
issel = opSelect;

if (strcmp(cmd, 'disptext'))
  if (~isempty(spAudioPlayer) && spAudioPlayer.isplaying)
    set(opPlayBut, 'Callback', 'opPlay(''stopplay'')', ...
      'String', 'Stop Playback');
  else
    set(opPlayBut, 'Callback', 'opPlay(''button'')', ...
      'String', iff(issel, 'Play Selection', 'Play Screen'));
  end
  return

elseif (   strcmp(cmd,'getinterp')...
        || strcmp(cmd,'setratetext') ...
	|| strcmp(cmd,'setrate') ...
	|| strcmp(cmd,'othercallback')...
       )
  [def,var] = defaultsrate;
  if (var)
    mult = 1;	                          % multiplier factor for 1x
    z = [20 10 5 2 1 1/2 1/5 1/10 1/20];
  else
    mult = def(1) / opSRate;
    z = mult * 0.5 .^ (0 : max(5, round(log2(mult))));
  end
  o = iff(var, opPlayOthers, opPlayOthers(opPlayOthers < mult));
  z = fliplr(uniq(sort([z o])));

  if (strcmp(cmd, 'getinterp'))		% return interpolation factor
    factor = -mult / z(opPlayRate);
    if (~var), factor = max(1, round(-factor)); end
    var = z(opPlayRate);			% second return value

  elseif (strcmp(cmd, 'setratetext'))		% set popup string
    s = 'Playback rate';
    x = z > 2/3;		% 2/3 is so round(1/z) is an integer > 1
    if (any(x)),  s = [s, sprintf('|    %.3gx  ', z(x))];              end
    if (any(~x)), s = [s, sprintf('|  1/%.3gx  ', round(1 ./ z(~x)))]; end
    s = [s,'|  Other...'];
    set(opPlayRateMenu, 'String', s, 'Value', opPlayRate + 1);

  elseif (strcmp(cmd, 'setrate'))		% user chose something on popup
    x = get(opPlayRateMenu, 'value');
    if (x == 1 || x == length(z)+2)		% 'Play rate' or 'Other...'
      set(opPlayRateMenu, 'value', opPlayRate+1);
      if (x ~= 1)
	uiInput('Playback rate', 'OK|Cancel', 'opPlay(''othercallback'');', ...
	    [], 'Enter playback rate multiplier: a number or an expression like 1/27.');
      end
    else opPlayRate = x - 1;			% the user picked a value
    end

  elseif (strcmp(cmd, 'othercallback'))		% callback from 'Other...'
    if (uiInputButton ~= 1), return; end	% Cancel
    if (isempty(uiInput1)), return; end		% empty user input
    v = eval(uiInput1);
    if (isempty(v)), disp('Empty playback rate value.  Ignored.'); return; end
    v = v(1);
    if (~var && v > mult)
      uiInput(char('Rate too big', ...
        ['Rate cannot be greater than ' num2str(mult) '.']), 'OK', ' ');
    else
      opPlayOthers = [opPlayOthers, v];
      opPlayRate = length(find(v < z)) + 1;
      opPlay('setratetext');
    end

  else
    error(['Internal error: Bad command ''', cmd, '''.']); 
  end
  return

elseif (strcmp(cmd, 'all'))
  t0 = 0; t1 = opTMax;		% whole sound

elseif (strcmp(cmd, 'button'))
  if (issel), t0 = opSelT0(opc); t1 = opSelT1(opc);	% selection
  else        t0 = opT0;    t1 = opT1;	% screen
  end

elseif (strcmp(cmd, 'movie'))
  if (~gexist4('opEpsDir'))
    opEpsDir = pathDir(opFileName('getsound'));
  end
  [f,p] = uiputfile1([opEpsDir filesep '*.avi'], ...
      'Save video of sound playback as...');
  if (ischar(f))
    opEpsDir = p;
    set(opFig, 'HandleVis', 'on')
    opPlay('button', fullfile(p, f));
    set(opFig, 'HandleVis', 'callback')
  end
  return
  
elseif (strcmp(cmd, 'stopplay'))
  % Stop sound playback (possible only if using audioplayer).
  if (~isempty(spAudioPlayer) && spAudioPlayer.isplaying)
    stop(spAudioPlayer);
  end
  % Stop the displayed moving bar.
  if (~isempty(opPlayTimer))
    stop(opPlayTimer);
  end
  % Fix the on-screen button.
  opPlay('disptext')
  set(opPlayBut, 'Callback', 'opPlay(''button'')')
  return
  
else
  error(['Unknown command in opPlay: ', cmd]);
end

% Control falls through to here if there is no explicit return.

% Play the sound between times t0 and t1, or make a movie.
s0 = max(round(t0 * opSRate), 0);
s1 = min(round(t1 * opSRate), opNSamp);
if (s1 > s0)
  opPointer('watch');
  snd = opSoundIn(s0, s1-s0, opc);
  
  if (0)
    [B,A] = designFilter('butter', 512000, [100000 150000], [90000 170000], 5, 50);
    snd = filter(B,A,snd);
  end
  
  [~,var] = defaultsrate;
  [interp,purefactor] = opPlay('getinterp');
  % Create a timer for the moving bar.  Also makes movie if needed.
  pd = round(1000/opFps) / 1000;			% timer period, s
  tm = timer('ExecutionMode', 'FixedRate', 'Period', pd, ...
    'StartFcn', {@opPlayLine, purefactor, [t0 t1], avifilename}, ...
    'TimerFcn', @opPlayLine, ...
    'StopFcn',  @opPlayLine, ...
    'TasksToExecute', (t1 - t0) / pd / purefactor, ...
    'BusyMode', iff(length(avifilename), 'queue', 'drop'));
  opPlayTimer = tm;
  startT = now;
  if (~isempty(avifilename))
    % Make the sound file.  The movie file is made in opPlayLine via start(tm).
    sfile = [pathRoot(avifilename) '.wav'];
    printf; printf('Creating movie %s .', avifilename);
    printf
    printf('Warning: This movie has no sound. Matlab does not [yet] provide')
    printf('any way to store sound along with video in an AVI file.')
    if (~exist(sfile, 'file'))
      printf('But I will store the sound as a separate sound file,')
      printf('%s', sfile);
      soundOut(sfile, snd, opSRate * purefactor);	% movie is made below
    else
      printf('(Not saving %s with the movie because it already exists.)',sfile)
    end
    printf
    printf('Another warning: Sometimes MATLAB does not save AVI movies')
    printf('correctly. If your movie appears with smeary diagonal lines,')
    printf('try changing the width of the Osprey window very slightly and')
    printf('then re-making the movie.')
  else
    % Play the sound.
    if (exist('resample', 'file') == 2)
      r = opSRate * opPlayCorrection / (-interp);
      soundPlay(snd - mean(snd), 1, r);
    elseif (interp >= 0)
      soundPlay(snd - mean(snd), abs(interp));
    else
      r = opSRate * opPlayCorrection / (-interp);
      soundPlay(snd - mean(snd), 1, r);
    end
  end
  opPointer('crosshair');
  opPlay('disptext');
end

% Attempt to fix the time offset between the moving bar and the playback.
x = get(tm, 'UserData');
x{1} = startT;
x{1} = 0;
set(tm, 'UserData', x)

start(tm);			% start bar; also creates movie file if needed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function opPlayLine(timer, event, purefactor, t, avifilename)
% Draw and animate the vertical line.
% Also save it as a movie if avifilename is given.

global opSRate opAxes opFig opFps opDateFix opc spAudioPlayer

% Internal data are kept as a cell array in the timer's UserData field:
%    UserData{1} is the clock time that this timer started
%    UserData{2} is the vertical line object
%    UserData{3} is the start time of the selection, namely t0 (in the gram)
%    UserData{4} is the end   time of the selection, namely t1 (in the gram)
%    UserData{5} is purefactor
%    UserData{6} is the avifile object, if any, for saving a movie to a file;
%                  present only if we're making an AVI movie

%printf('opPlayLine: event %s, time %g', event.Type, event.Data.time(6))

switch event.Type
case 'StartFcn'
  is_movie = ((nargin >= 5) && ~isempty(avifilename));
  axes(opAxes(opc));                                              %#ok<*MAXES>
  u{1} = datenum(event.Data.time);
  u{2} = line(t([1 1])+opDateFix, [0 opSRate/2], 'Color','r','LineWidth',1.5);
  u{3} = t(1);
  u{4} = t(2);
  u{5} = purefactor;
  if (is_movie)
    fn = opFileName('getsound');
    u{6} = avifile(avifilename, 'colormap', get(opFig, 'Colormap'), ...
	'fps', opFps, 'videoname', fn(1 : min(64, length(fn))), ...
	'quality', 100, 'keyframe', 1.0, 'compression', 'none');
  end
  set(timer, 'UserData', u);
  opPlayAddFrame(timer, u);          % make first frame have no red line

case 'TimerFcn'
  % u is {clockStartTime lineObj t0 t1 purefactor optionalAviFile}
  u = get(timer, 'UserData');
  t0 = u{3};
  t1 = u{4};
  purefactor = u{5};
  % Real playback uses real time; in movie-making, just count frames.
  tNow = t0 + (datenum(event.Data.time)-u{1})*24*60*60*purefactor;
  if (length(u) >= 6)                   % AVI movie?
    tNow = t0 + get(timer,'TasksExecuted') / opFps * purefactor; 
  end
  if (~ishandle(u{2}))     % happens if user scrolls during playback
    axes(opAxes(opc));
    u{2} = line([1 1], [0 opSRate/2], 'Color','r','LineWidth',1.5);%fix time below
    set(timer, 'UserData', u)
  end
  set(u{2}, 'XData', tNow * [1 1] + opDateFix);
  drawnow
  opPlayAddFrame(timer, u)
  if (tNow > t1)
    stop(timer);
  end

case 'StopFcn'
  u = get(timer, 'UserData');
  if (ishandle(u{2})), delete(u{2}); end        % remove the line
  opPlayAddFrame(timer, u);			% add frame with no line
  if (length(u) >= 6)				% close the AVI file?
    u{6} = close(u{6});				% close requires output arg
    set(timer, 'UserData', u);			% but u is soon to be deleted
  end  
  delete(timer);                                % remove the timer
  spAudioPlayer = [];				% playback is ending
  opPlay('disptext');                           % fix button text & callback
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function opPlayAddFrame(timer, u)
% If needed, add another frame to the movie.  The framesize must be a
% multiple of 4.

global opAxes opFig opc

if (length(u) >= 6)                    % is there an AVI movie?
  % p has margins so as to include the axis ticks.
  p = get(opAxes(opc), 'Pos') + [-68 -48 80 56];
  f = getframe(opFig, [p(1:2)  p(3:4)-mod(p(3:4),4)]); % make multiple of 4
  u{6} = addframe(u{6}, f);
  set(timer, 'UserData', u);
end
