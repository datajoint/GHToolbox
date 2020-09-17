[![View GHToolbox on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/80245-ghtoolbox)

# GitHub Toolbox Utility

## Summary

`ghtb` provides a simple way to manage toolbox installation of open-source MATLAB Community Toolboxes linked to GitHub (via Releases). https://www.github.com/guzman-raphael/GHToolbox.git

## Description

This Toolbox can be accessed via `ghtb` and provides a way to directly `install` or `uninstall` MATLAB Community Toolboxes. For upgrade and downgrade use-cases, users can set the `override` option to force the install. `GHToolbox` makes the following assumptions:

- Community Toolbox linked on FileExchange to GitHub via GitHub Releases.
- Community Toolbox publicly available as open-source on GitHub.
- Community Toolbox attaches a single `.mltbx` artifact to GitHub Releases.
- Community Toolbox name matches the filename of `.mltbx` artifact.
- Users do not wish to have multiple simultaneous versions installed i.e. only a single version per Toolbox is installed at any given time.

Here are some examples on how to invoke it once installed or saved to path:

```matlab
ghtb.install('guzman-raphael/compareVersions') % default: version='latest' and override=false
ghtb.install('guzman-raphael/compareVersions', 'version', '1.0.5') % default: override=false
ghtb.install('guzman-raphael/compareVersions', 'version', '1.0.4', 'override', true)
ghtb.uninstall('compareVersions') % uninstalls all versions of Toolbox
ghtb.version % display GHToolbox version
```