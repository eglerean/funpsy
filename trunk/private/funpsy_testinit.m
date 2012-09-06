%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNPSY toolbox for fMRI functional phase syncrhony
%
% RELEASE: 0.1 alpha
% CODE VERSION: 0.1.5.23
% LAST MODIFIED: 2011/05/23
% URL: http://becs.tkk.fi/~eglerean/
% RSS: https://blogs.aalto.fi/enricoglerean/feed/
%
% developed & mantained by: Enrico Glerean - enrico.glerean@aalto.fi
% collaborators and co-authors: 
%   - Juha Lahnakoski
%   - Juha Salmi
%   - Jouko Lampinen
%   - Jukka-Pekka Kauppi
%   - Iiro Jääskeläinen
%   - Mikko Sams
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% COPYRIGHT NOTICE
%  IF YOU EDIT THE BELOW PLEASE DO NOT REDISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL AUTHOR
%%

function funpsy_testinit(psess,processID)

isinit=0;
if(isfield(psess.history,'init'))
    if(psess.history.init == 1)
        isinit=1;
    end
end       

if(isinit == 0)
    error([processID 'The session ' cfg.sessionfile ' was not initialized']);
end