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
        function TestManage_testVersionHandle(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            version_handle = @(v) cellfun(@(x) strcmp(x, '1.0.9'), v, 'uni', true);
            ghtb.install(...
                'guzman-raphael/compareVersions', 'version', version_handle, 'override', true);
            toolboxes = matlab.addons.toolbox.installedToolboxes;
            tb_version = toolboxes(strcmp('compareVersions', {toolboxes.Name})).Version;
            testCase.verifyTrue(compareVersions({tb_version}, '1.0.9', ...
                                                @(curr_v,ref_v) curr_v==ref_v));
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