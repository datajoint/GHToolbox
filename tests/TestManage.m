classdef TestManage < matlab.unittest.TestCase
    % TestManage_testOverride checks if you can install latest and then override with
    % prior release.
    methods (Test)
        function TestManage_testOverride(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            ghtb.version
            ghtb.install('guzman-raphael/compareVersions', 'version', 'latest');
            toolboxes = matlab.addons.toolbox.installedToolboxes;
            tb_version = toolboxes(strcmp('compareVersions', {toolboxes.Name})).Version;
            latest_ver = sum(cellfun(@(x) str2num(x), strsplit(tb_version, '.'), ...
                                     'UniformOutput', true));

            ghtb.install(...
                'guzman-raphael/compareVersions', 'version', '1.0.6', 'override', true);
            toolboxes = matlab.addons.toolbox.installedToolboxes;
            tb_version = toolboxes(strcmp('compareVersions', {toolboxes.Name})).Version;
            testCase.verifyTrue(sum(cellfun(@(x) str2num(x), strsplit(tb_version, '.'), ...
                                            'UniformOutput', true)) < latest_ver);
            ghtb.uninstall('compareVersions');
        end
        function TestManage_initialize(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            ghtb.initialize('prompt', false);
            ghtb.initialize;
        end
    end
end