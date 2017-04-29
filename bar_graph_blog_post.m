%=============================================================================================
% LED Bar Graph LED Position Eagle Script Generator
% Copyright 2016-2017 by Glen Akins.
% All rights reserved.
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%=============================================================================================

% all dimensions in millimeters

nLedPos = 32;       % number of LEDs in a complete circle
nLeds = 24;         % number of LEDs in this bar graph
r = 18.5;           % radius of LED arc
xOffset = 25;       % x offset to center of arc of LEDs
yOffset = 25;       % y offset to center of arc of LEDs
keepout = 9;        % width of keepout region across each LED
radius = 25.4;      % radius of board
ledw = 5 + 0.2;     % 3d printed led hole width = led width + total spacing
ledh = 1 + 0.2;     % 3d printed led hole height = led height + total spacing

% spacing between LEDs in degrees
dtheta = 360 / nLedPos;

% position of bottom most LED on the left side of the arc in degrees
itheta = 360 / nLedPos / 2;
itheta = itheta + nLedPos * dtheta * 3 / 4 - dtheta;
itheta = itheta - (nLedPos - nLeds) / 2 * dtheta;

% open script file
fout = fopen ('bar_graph_blog_post.scr', 'w');

% change bend style to straight line
fprintf (fout, 'SET WIRE_BEND 2;\n');

% add the board outline
fprintf (fout, 'layer 20;\n');
fprintf (fout, 'circle 0.1mm (%fmm %fmm) (%fmm %fmm);\n', xOffset, yOffset, xOffset, xOffset-radius);

% change to tdocu layer
fprintf (fout, 'layer 51;\n');

% add commands to move and rotate D1 ... Dx to their correct positions
for led = 0:nLeds-1
    theta = itheta - led * dtheta;
    rads = theta / 180 * pi;
    x = round (100 * (xOffset + r*cos (rads))) / 100;
    y = round (100 * (yOffset + r*sin (rads))) / 100;
    fprintf (fout, 'move D%d (%-0.2fmm %-0.2fmm);\n', led+1, x, y);
    fprintf (fout, 'rotate =R%-0.2f D%d;\n', theta, led+1);
    
    x1 = x + (ledw/2 * cos (rads) - ledh/2 * sin (rads));
    y1 = y + (ledw/2 * sin (rads) + ledh/2 * cos (rads));
    x2 = x + (ledw/2 * cos (rads) - -ledh/2 * sin (rads));
    y2 = y + (ledw/2 * sin (rads) + -ledh/2 * cos (rads));
    x3 = x + (-ledw/2 * cos (rads) - -ledh/2 * sin (rads));
    y3 = y + (-ledw/2 * sin (rads) + -ledh/2 * cos (rads));
    x4 = x + (-ledw/2 * cos (rads) - ledh/2 * sin (rads));
    y4 = y + (-ledw/2 * sin (rads) + ledh/2 * cos (rads));
    
    fprintf (fout, 'wire 0.1mm (%fmm %fmm) (%fmm %fmm);\n', x1, y1, x2, y2);
    fprintf (fout, 'wire 0.1mm (%fmm %fmm) (%fmm %fmm);\n', x2, y2, x3, y3);
    fprintf (fout, 'wire 0.1mm (%fmm %fmm) (%fmm %fmm);\n', x3, y3, x4, y4);
    fprintf (fout, 'wire 0.1mm (%fmm %fmm) (%fmm %fmm);\n', x4, y4, x1, y1);
end

% add a keep out region on the top documentation layer
fprintf (fout, 'layer 51;\n');

% radius of keep out regions
r1 = r - keepout / 2;
r2 = r + keepout / 2;

if (nLedPos == nLeds)
    % use complete circles if all LED positions used
    fprintf (fout, 'circle 0.1mm (%fmm %fmm) (%fmm %fmm);\n', xOffset, yOffset, xOffset, xOffset - r1);
    fprintf (fout, 'circle 0.1mm (%fmm %fmm) (%fmm %fmm);\n', xOffset, yOffset, xOffset, xOffset - r2);
else
    % use arcs if not all LED positions used
    fprintf (fout, 'change width 0.1mm;\n');
    
    % bottom left position of arcs in degrees and radians
    d1 = (itheta + dtheta / 2);
    rads = d1 / 180 * pi;
    
    % polar to rectangular for bottom left coordinate for inside arc
    x10 = round (100 * (xOffset + r1 * cos (rads))) / 100;
    y10 = round (100 * (xOffset + r1 * sin (rads))) / 100;
    
    % polar to rectangular for bottom left coordinate for outside arc
    x20 = round (100 * (xOffset + r2 * cos (rads))) / 100;
    y20 = round (100 * (xOffset + r2 * sin (rads))) / 100;
    
    % bottom right position of arcs in degrees and radians
    d2 = (itheta - nLeds * dtheta + dtheta / 2);
    rads = d2 / 180 * pi;
    
    % polar to rectangular for bottom right coordinate for inside arc
    x11 = round (100 * (xOffset + r1 * cos (rads))) / 100;
    y11 = round (100 * (xOffset + r1 * sin (rads))) / 100;

    % polar to rectangular for bottom right coordinate for outside arc
    x21 = round (100 * (xOffset + r2 * cos (rads))) / 100;
    y21 = round (100 * (xOffset + r2 * sin (rads))) / 100;

    fprintf (fout, 'wire 0.1mm (%fmm %fmm) (%fmm %fmm);\n', x10, y10, x20, y20);
    fprintf (fout, 'wire 0.1mm (%fmm %fmm) (%fmm %fmm);\n', x11, y11, x21, y21);

    fprintf (fout, 'wire 0.1mm (%fmm %fmm) -%f (%fmm %fmm);\n', x10, y10, d1-d2, x11, y11);
    fprintf (fout, 'wire 0.1mm (%fmm %fmm) -%f (%fmm %fmm);\n', x20, y20, d1-d2, x21, y21);
end

% close script file
fclose (fout);

