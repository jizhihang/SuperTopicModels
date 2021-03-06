function ybar = getRealValuedRegressionOutcomes( Data, barZ, eta, model )
% Regardless of regression/classification,
%   we use a sampler procedure that requires a real-valued response "ybar"
%    for each document d in the collection
% For regression
%   this response is just the given y values.
% For binary classification,
%   this response is a hidden auxiliary variable "ybar_d"
%   Generatively,
%       ybar_d ~ Normal( \bar{z}_d ^T eta, 1 ) %Note fixed precision=1
%       y_d <--  1 if ybar > 0
%               0 o.w.
%   So given the classifier outcome y_d, we sample ybar_d
%       via a *truncated* normal distribution (see randn_trunc.m)


yorig = vertcat( Data(:).y );
if isvector(eta)
    ybar = nan( size(yorig) );
else
    ybar = nan( size(yorig,1), size(eta,2) );
end
D =size(yorig, 1);

seeds = randint( D,1, [0 1e5]); % get D rand ints, each within [0,1e5]

if model.RegM.doBinary
    for dd = 1:D        
        % FAST WAY with MEX
        ybar(dd) = randn_trunc_MEX( barZ(dd,:)*eta, 1, yorig(dd), 2, seeds(dd) );
        
        % SLOW WAY with pure matlab
        %ybar(dd) = randn_trunc( barZ(dd,:)*eta, 1, yorig(dd) );
    end
elseif model.RegM.doMultiClass
    for dd = 1:D
        % FAST WAY with MEX
        % sometimes this line gives funny errors.
        %  Contact Mike for debug advice
        ybar(dd,:) = mv_randn_trunc_MEX( (barZ(dd,:)*eta)', yorig(dd), 1, seeds(dd) );
        
        % SLOW WAY with pure matlab
        %ybar(dd,:) = mv_randn_trunc( (barZ(dd,:)*eta)',  yorig(dd) );
    end
else
    ybar = yorig;
end

end