# Linear vertical vibrations of a  suspension bridge

[![View Linear vertical vibrations of suspension bridges on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://se.mathworks.com/matlabcentral/fileexchange/54649-linear-vertical-vibrations-of-suspension-bridges)
[![DOI](https://zenodo.org/badge/263912798.svg)](https://zenodo.org/badge/latestdoi/263912798)

## Summary

The vertical eigenfrequencies and mode shapes of a single-span suspension bridge are computed using the method by Luco et Turmo [1]. For the sake of completeness, the computed modal parameters are compared with those obtained using the method by Sigbjørnsson & Hjorth-Hansen [2] and Strømmen [3].


## Content
The submission contains:
- eigenBridge.m (it is identical to File ID: #51815) and is inspired from [5,6]
- eigenridge2.m based on works of [4]. I am simply writing the equations and their solutions in a numerical way.
- eigBridge_Verification.m: its only purpose is to verify the numerical implementation of eigenBridge2.m
- Verifications.mlx : It is a verification of the works of [4], where I try to obtain exactly what [4] show in their paper.
- Application.mlx: I compare eigenBridge.m with eigenBridge2.m

Any comment or idea of improvement is warmly welcome.

## References

[1] Luco, J. E., & Turmo, J. (2010). Linear vertical vibrations of suspension bridges: A review of continuum models and some new results. Soil Dynamics and Earthquake Engineering, 30(9), 769-781.

[5] Sigbjørnsson, R., Hjorth-Hansen, E.: Along wind response of suspension bridges with special reference to stiffening by horizontal cables. Engineering Structures 3, 27–37 (1981)

[6] Structural Dynamics, Einar N Strømmen, Springer International Publishing, 2013. ISBN: 3319018019, 783319018010
