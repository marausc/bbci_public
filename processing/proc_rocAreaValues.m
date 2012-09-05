function fv_roc= proc_rocAreaValues(fv, varargin)
%PROC_ROCAREAVALUES - Measure of Discriminability based on ROC Curves
%
%Synopsis:
% FV_ROC= proc_rocAreaValues(FV)
%
%Arguments:
% FV: Feature vector structure
%
%Returns:
% FV_OUT: Feature vector structure of roc values.
%
%Description:
%For each feature dimension, the area under the ROC curve is calculated,
%and the rocAreaValue is determined as 2*(0.5-area), i.e., the value is
%-1 if all samples of class 1 have smaller values than any sample of 
%class 2, and the value is 1 if all samples of class 1 have larger 
%values than any sample of class 2.
%For data with more than two classes, pairwise roc values are calculated.
%
%See also:
% proc_rValues, proc_rSquaredSigned, proc_tTest

% Author(s): Benjamin Blankertz, Feb 2006
props= {'multiclassPolicy' 'pairwise' 'CHAR'};

if nargin==0,
  fv_roc= props; return
end

fv = misc_history(fv);
misc_checkType(dat, 'STRUCT(x)'); 

opt= opt_proplistToStruct(varargin{:});
[opt, isdefault]= opt_setDefaults(opt, props);
opt_checkProplist(opt, props);

if size(fv.y,1)>2, 
  fv_roc= procutil_multiclassDiff(fv, {'rocAreaValues',opt}, ...
                                  opt.multiclassPolicy);
  return;
end
  
sz= size(fv.x);
fv.x= reshape(fv.x, [prod(sz(1:end-1)) sz(end)]);

roc= zeros(size(fv.x,1), 1);
for k= 1:size(fv.x,1),
  [dmy, auc]= val_rocCurve(fv.y, fv.x(k,:));
  roc(k)= 2*(0.5-auc);
end

fv_roc= fv;
fv_roc.x= reshape(roc, [sz(1:end-1) 1]);
if isfield(fv, 'className'),
  fv_roc.className= {sprintf('roc( %s , %s )', fv.className{1:2})};
end
fv_roc.y= 1;
fv_roc.yUnit= 'roc';
