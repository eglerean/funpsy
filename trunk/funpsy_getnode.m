function ts = funpsy_getnode(cfg)
%FUNPSY_GETNODE will extract all the link time series attached to a node ID.
%   ts=funpsy_getnode(cfg) returns a vector with T = timepoints rows and N columns as the number of nodes. 
%	The column equal to the current node is included as a vector of ones
%   'cfg' is a struct with mandatory parameters
%       cfg.psess = psess; the session variable
%		cfg.noi = nodeID; the node of interest (noi)

%% COPYRIGHT NOTICE
%  IF YOU EDIT OR REUSE PART OF THE BELOW PLEASE DO NOT RE-DISTRIBUTE WITHOUT NOTIFYING THE ORIGINAL AUTHOR
%  IF YOU PUBLISH PLEASE QUOTE THE ORIGINAL ARTICLE
%%

psess = cfg.psess;
R = length(psess.rois);
noi = cfg.noi;
if(noi<1 || noi>R)
	error(['Node of interest is out of range 1-' num2str(R)])
end

if(ismember(noi,psess.blacklsit))
	error(['You do not want to use a node that is on the blacklist']);
end

ts=ones(psess.T,R);
for r=1:R
	disp(num2str(r));
	if(r>noi)
		break
	end
	load([psess.results.sbps num2str(r)]); % sbpsts 
	if(r<noi)
		ts(:,r)=sbpsts(:,noi-r);
	end
	if(r==noi)
		ts(:,(r+1):end)=sbpsts;
	end
end
