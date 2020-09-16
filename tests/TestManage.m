classdef TestManage < matlab.unittest.TestCase
    % TestManage_testOverride checks if you can install latest and then override with
    % prior release.
    methods (Test)
        function TestManage_testOverride(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            ghtb.install('guzman-raphael/compareVersions', 'version', 'latest');
            addons = matlab.addons.installedAddons;
            versions = addons.Version(addons.Name == 'compareVersions');
            latest_ver = sum(cellfun(@(x) str2num(x), split(versions{1}, '.'), ...
                                     'UniformOutput', true));

            ghtb.install(...
                'guzman-raphael/compareVersions', 'version', '1.0.4', 'override', true);
            addons = matlab.addons.installedAddons;
            versions = addons.Version(addons.Name == 'compareVersions');
            testCase.verifyTrue(sum(cellfun(@(x) str2num(x), split(versions{1}, '.'), ...
                                            'UniformOutput', true)) < latest_ver);
        end
    end
end