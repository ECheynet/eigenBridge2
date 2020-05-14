function [fn,phi] = eigenBridge2(Bridge,mu,lambda,Nmodes)
% [fn,phi] = eigenBridge2(Bridge,mu,lambda,Nmodes)compute the eigen 
% frequencies and mode shapes following the method proposed by Luco et al. [1]
% 
% [1] Luco, J. E., & Turmo, J. (2010).
% Linear vertical vibrations of suspension bridges:
% A review of continuum models and some new results.
% Soil Dynamics and Earthquake Engineering,
% 30(9), 769-781.
% 
%  INPUTS
% Bridge: structure [1 x Nyy] Non-dimensional bridge span discretized in Nyy points
% mu: positive scalar: relative bending stifness of the girder
% lambda: positive scalar: Irvine-Caughy vable parameter
% Nmodes: positive natural: Number of modes to be computed
% 
% OUTPUTS
% fn: scalar: eigen frequencies (Hz)
% phi: vector [1 x Nyy] of normalized mode shapes
% 
% Author info:
% E. Cheynet , University of Stavanger. last modified: 31/10/2019
%
% see also eigenBridge
% 

%% shorten the variable x

x = Bridge.x;
% Number of integration points
Nyy = numel(x);
% non-dimensionla pulsation
CST = (2*pi*[1:1:Nmodes]);
%% antisymmetric modes and eigen frequencies
% egien-frequencies
w_a = CST.*sqrt(1+(CST.*mu).^2);
fn_a = w_a./(2*pi*sqrt(8*Bridge.sag/Bridge.g));
% mode shapes
phi_a = sin(2*pi.*[1:1:Nmodes]'*x);

%% Symmetric eigen frequencies and mode shapes

% Here there are 2 steps:
% 1) Solve a characteristic equation to find w
% 2) Report omega into the analytical expression of the mode shape

% 1) Solve the characteristic equation
% Nmber of solutions Nsol: be careful not to choose too many modes !
Nsol = max(200,Nmodes^3);
dummy = zeros(1,Nsol);
% check matlab version
checkMatlabVersion = version;

% First, we need too check if lambda is not too close to zero,
% i.e. below 0.1. Otherwise it is assumed to be an inelastic cable.
if lambda >0.1,
    if str2double(checkMatlabVersion(end-5:end-2))<=2012, % R2012b or earlier
        for ii=1:Nsol,
            dummy(ii) =fsolve(@(w) charFun(w,mu,lambda),ii,...
                optimset('Display','off','TolFun', 1e-8, 'TolX', 1e-8));
        end
    elseif str2double(checkMatlabVersion(end-5:end-2))>=2013, % R2013a or later
        for ii=1:Nsol,
            dummy(ii) =fsolve(@(w) charFun(w,mu,lambda),ii,...
                optimoptions('fsolve','Display','off',...
                'TolFun', 1e-8, 'TolX', 1e-8));
        end
    end
    
    % Analytically, many solutions are identical to each other,
    % but numerically, it is not the case.
    % Therefore I need to limit the prceision of the solutions to 1e-3.
    dummy = unique(round(dummy*1e3).*1e-3);
    % remove the first solution that is found to be meaningless
    dummy(dummy<1e-1)=[];
    % Check if any  issues:
    if isempty(dummy), % no solutions found
        warning('no mode shapes found');
        w_a =NaN(1,Nmodes);
        w_s =NaN(1,Nmodes);
        phi_a=NaN(Nmodes,Nyy);
        phi_s=NaN(Nmodes,Nyy);
        return
    elseif numel(dummy)<Nmodes, % less solutions than Nmodes found
        warning('not enough mode shapes found');
        w_a =NaN(1,Nmodes);
        w_s =NaN(1,Nmodes);
        phi_a=NaN(Nmodes,Nyy);
        phi_s=NaN(Nmodes,Nyy);
        return
    end
    % Limit the number of solutions to Nmodes
    w_s=dummy(1:Nmodes);
    % Get the mode shapes
    phi_s = zeros(Nmodes,Nyy);
    for ii=1:Nmodes
        [phi_s(ii,:)] = modeShapeFun(x,mu,lambda,w_s(ii));
    end
else % case of an inelastic cable, i.e. lambda = 0
    N = 2.*[1:1:Nmodes]-1;
    dummy = N.*pi.*sqrt(1+(N.*pi.*mu).^2);
    w_s=dummy(1:Nmodes); % eigen-frequencies
    phi_s = sin(N'*x.*pi); % mode shapes eigenBridge
end
fn_s = w_s./(2*pi*sqrt(8*Bridge.sag/Bridge.g));

[fn,ind] = sort([fn_a,fn_s]);
phi = [phi_a;phi_s];
phi = phi(ind,:);

fn = fn(1:Nmodes);
phi = phi(1:Nmodes,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Nested functions
    function H = charFun(w,mu,lambda)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % GOAL: choose the corresponding characteristic equation
        % INPUT
        %   w: Non dimensional eigen frequency (unknown)
        %   mu: positive scalar: relative bending stifness of the girder
        %   lambda: positive scalar: Irvine-Caughy vable parameter
        % OUTPUT: H: Characteristic equation to be solved for w
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if mu<=1e-6, % case of a perfectly flexible deck (limit case)
            H = 1-(w/lambda).^2-tan(w/2)/(w/2);
        elseif mu>=1e6, % very stiff deck ( limit case)
            A = sqrt((sqrt(1+(2*mu*w).^2)-1)/(2*mu^2));
            H = 1-(A*mu/lambda).^2-(1/2)*tan(A/2)/(A/2)-...
                (1/2)*tanh(A/2)/(A/2);
        else
            A = sqrt((sqrt(1+(2*mu*w).^2)-1)/(2*mu^2));
            B = sqrt((sqrt(1+(2*mu*w).^2)+1)/(2*mu^2));
            H = 1-(w/lambda).^2-(B^2/(A^2+B^2))*tan(A/2)/(A/2)-...
                (A^2/(A^2+B^2))*tanh(B/2)/(B/2);
        end
    end

    function [phi] = modeShapeFun(x,mu,lambda,omega)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % GOAL: calculate the mode shapes
        % INPUT
        %   x:  [1 x Nyy] vector of non-dimensional deck span
        %   mu: positive scalar: relative bending stifness of the girder
        %   lambda: positive scalar: Irvine-Caughy vable parameter
        %   omega: Non dimensional eigen frequency (it is now known)
        % OUTPUT: phi: [1 x Nyy] vector of mode shape
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if mu<=1e-6, % case of a perfectly flexible deck (limit case)
            dummyPhi = (lambda.*omega).^2.*(1-cos(omega*(x-1/2))/cos(omega/2));
            phi = dummyPhi./max(abs(dummyPhi));% normalization
        elseif mu>=1e6, % very stiff deck ( limit case)
            A = sqrt((sqrt(1+(2*mu*omega).^2)-1)/(2*mu^2));
            dummyPhi = (1-0.5*cos(A*(x-1/2))/cos(A/2)-...
                0.5*cosh(A*(x-1/2))/cosh(A/2));
            phi = dummyPhi./max(abs(dummyPhi));% normalization
        else
            A = sqrt((sqrt(1+(2*mu*omega).^2)-1)/(2*mu^2));
            B = sqrt((sqrt(1+(2*mu*omega).^2)+1)/(2*mu^2));
            dummyPhi = (lambda.*omega).^2.*(1-(B.^2/(A.^2+B.^2))*cos(A*(x-1/2))/cos(A/2)-...
                (A.^2/(A.^2+B.^2))*cosh(B*(x-1/2))/cosh(B/2));
            phi = dummyPhi./max(abs(dummyPhi)); % normalization
        end
        if abs(min(phi))>max(phi),
            phi=-phi; % positiv maximum
        end
    end



end

