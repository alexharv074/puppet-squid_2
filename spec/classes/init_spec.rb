require 'spec_helper'
describe 'squid' do
  readme_checked = false
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with defaults for all parameters' do
        it { is_expected.to contain_class('squid') }
        it { is_expected.to contain_class('squid::install') }
        it { is_expected.to contain_class('squid::config') }
        it { is_expected.to contain_class('squid::service') }
        case facts[:operatingsystem]
        when 'Debian'
          context 'when on Debian' do
            it { is_expected.to contain_package('squid3').with_ensure('present') }
            it { is_expected.to contain_service('squid3').with_ensure('running') }
            it { is_expected.to contain_concat('/etc/squid3/squid.conf').with_group('root') }
            it { is_expected.to contain_concat('/etc/squid3/squid.conf').with_owner('root') }
            it { is_expected.to contain_concat_fragment('squid_header').with_target('/etc/squid3/squid.conf') }
            it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^access_log}) }
          end
        when 'Ubuntu'
          case facts[:operatingsystemrelease]
          when '14.04'
            context 'when on Ubuntu 14.04' do
              it { is_expected.to contain_package('squid3').with_ensure('present') }
              it { is_expected.to contain_service('squid3').with_ensure('running') }
              it { is_expected.to contain_concat('/etc/squid3/squid.conf').with_group('root') }
              it { is_expected.to contain_concat('/etc/squid3/squid.conf').with_owner('root') }
              it { is_expected.to contain_concat_fragment('squid_header').with_target('/etc/squid3/squid.conf') }
              it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^access_log}) }
            end
          when '16.04'
            context 'when on Ubuntu 16.04' do
              it { is_expected.to contain_package('squid').with_ensure('present') }
              it { is_expected.to contain_service('squid').with_ensure('running') }
              it { is_expected.to contain_concat('/etc/squid/squid.conf').with_group('root') }
              it { is_expected.to contain_concat('/etc/squid/squid.conf').with_owner('root') }
              it { is_expected.to contain_concat_fragment('squid_header').with_target('/etc/squid/squid.conf') }
              it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^access_log}) }
            end
          end
        when 'FreeBSD'
          context 'when on FreeBSD' do
            it { is_expected.to contain_package('squid').with_ensure('present') }
            it { is_expected.to contain_service('squid').with_ensure('running') }
            it { is_expected.to contain_concat('/usr/local/etc/squid/squid.conf').with_group('squid') }
            it { is_expected.to contain_concat('/usr/local/etc/squid/squid.conf').with_owner('root') }
            it { is_expected.to contain_concat_fragment('squid_header').with_target('/usr/local/etc/squid/squid.conf') }
            it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^access_log}) }
          end
        else
          context 'when on any other supported OS' do
            it { is_expected.to contain_package('squid').with_ensure('present') }
            it { is_expected.to contain_service('squid').with_ensure('running') }
            it { is_expected.to contain_concat('/etc/squid/squid.conf').with_group('squid') }
            it { is_expected.to contain_concat('/etc/squid/squid.conf').with_owner('root') }
            it { is_expected.to contain_concat_fragment('squid_header').with_target('/etc/squid/squid.conf') }
            it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^access_log}) }
          end
        end
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^append_domain}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^cache\s+}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^cache_log}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^cache_mem}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^cache_mgr}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^cache_effective_group}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^cache_effective_user}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^maximum_object_size_in_memory}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^memory_cache_shared}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^coredump_dir}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^max_filedescriptors}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^via}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^visible_hostname}) }
        it { is_expected.to contain_concat_fragment('squid_header').without_content(%r{^workers}) }
      end

      context 'with all parameters set' do
        params = {
          config: '/tmp/squid.conf',
          append_domain: '.example.com',
          access_log: '/var/log/out.log',
          cache: 'deny all',
          cache_effective_group: 'squid',
          cache_effective_user: 'squid',
          cache_log: '/var/log/cache.log',
          cache_mem: '1024 MB',
          cache_mgr: 'webmaster@example.com',
          coredump_dir: '/tmp/core',
          logformat: 'squid %tl.%03tu %6tr %>a %Ss/%03Hs',
          max_filedescriptors: 1000,
          memory_cache_shared: 'on',
          via: 'off',
          visible_hostname: 'myhost.example.com',
          workers: 8
        }
        let(:params) { params }

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }

        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^append_domain                 .example.com$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^access_log                    /var/log/out.log$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^cache                         deny all$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^cache_effective_group         squid$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^cache_effective_user          squid$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^cache_log                     /var/log/cache.log$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^cache_mem                     1024 MB$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^coredump_dir                  /tmp/core$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^logformat                     squid %tl.%03tu %6tr %>a %Ss/%03Hs$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^max_filedescriptors           1000$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^memory_cache_shared           on$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^via                           off$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^visible_hostname              myhost.example.com$}) }
        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^workers                       8$}) }

        unless readme_checked
          it 'README should be updated' do
            content = File.read('README.md')
            params.keys.each do |p|
              unless content =~ /^\* \`#{p}\`.*\.$/
                puts "      Parameter #{p} not found or formatted correctly in README.md"
              end
              expect(content).to match /^\* \`#{p}\`.*\.$/
            end
          end
          readme_checked = true
        end
      end

      context 'with memory_cache_shared parameter set to a boolean' do
        let :params do
          {
            config: '/tmp/squid.conf',
            memory_cache_shared: true
          }
        end

        it { is_expected.to raise_error(Puppet::PreformattedError) }
      end

      context 'with memory_cache_shared parameter set to on' do
        let :params do
          {
            config: '/tmp/squid.conf',
            memory_cache_shared: 'on'
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^memory_cache_shared\s+on$}) }
      end

      context 'with memory_cache_shared parameter set to off' do
        let :params do
          {
            config: '/tmp/squid.conf',
            memory_cache_shared: 'off'
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_content(%r{^memory_cache_shared\s+off$}) }
      end

      context 'with one acl parameter set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            acls: {
              'myacl' => {
                'type' => 'urlregex',
                'order' => '07',
                'entries' => ['http://example.org/', 'http://example.com/']
              }
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_acl_myacl').with_order('10-07-urlregex') }
        it { is_expected.to contain_concat_fragment('squid_acl_myacl').with_content(%r{^acl\s+myacl\s+urlregex\shttp://example.org/$}) }
        it { is_expected.to contain_concat_fragment('squid_acl_myacl').with_content(%r{^# acl fragment for myacl$}) }
      end

      context 'with two acl parameters set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            acls: {
              'myacl' => {
                'type' => 'urlregex',
                'order' => '07',
                'entries' => ['http://example.org/', 'http://example.com/']
              },
              'mysecondacl' => {
                'type' => 'urlregex',
                'order' => '08',
                'entries' => ['http://example2.org/', 'http://example2.com/']
              }
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_acl_myacl').with_order('10-07-urlregex') }
        it { is_expected.to contain_concat_fragment('squid_acl_myacl').with_content(%r{^acl\s+myacl\s+urlregex\shttp://example.org/$}) }
        it { is_expected.to contain_concat_fragment('squid_acl_myacl').with_content(%r{^acl\s+myacl\s+urlregex\shttp://example.com/$}) }
        it { is_expected.to contain_concat_fragment('squid_acl_mysecondacl').with_order('10-08-urlregex') }
        it { is_expected.to contain_concat_fragment('squid_acl_mysecondacl').with_content(%r{^acl\s+mysecondacl\s+urlregex\shttp://example2.org/$}) }
        it { is_expected.to contain_concat_fragment('squid_acl_mysecondacl').with_content(%r{^acl\s+mysecondacl\s+urlregex\shttp://example2.com/$}) }
      end

      context 'with one http_access parameter set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            http_access: {
              'myrule' => {
                'action' => 'deny',
                'value' => 'this and that',
                'order' => '08'
              }
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_http_access_this and that').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_http_access_this and that').with_order('20-08-deny') }
        it { is_expected.to contain_concat_fragment('squid_http_access_this and that').with_content(%r{^http_access\s+deny\s+this and that$}) }
      end

      context 'with two http_access parameters set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            http_access: {
              'myrule' => {
                'action' => 'deny',
                'value'  => 'this and that',
                'order'  => '08'
              },
              'secondrule' => {
                'action'  => 'deny',
                'value'   => 'this too',
                'order'   => '09',
                'comment' => 'Deny this and too'
              }
            }

          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_http_access_this and that').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_http_access_this and that').with_order('20-08-deny') }
        it { is_expected.to contain_concat_fragment('squid_http_access_this and that').with_content(%r{^http_access\s+deny\s+this and that$}) }
        it { is_expected.to contain_concat_fragment('squid_http_access_this and that').with_content(%r{^# http_access fragment for this and that$}) }
        it { is_expected.to contain_concat_fragment('squid_http_access_this too').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_http_access_this too').with_order('20-09-deny') }
        it { is_expected.to contain_concat_fragment('squid_http_access_this too').with_content(%r{^http_access\s+deny\s+this too$}) }
        it { is_expected.to contain_concat_fragment('squid_http_access_this too').with_content(%r{^# Deny this and too$}) }
      end

      context 'with one ssl_bump parameter set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            ssl_bump: {
              'myrule' => {
                'action' => 'bump',
                'value' => 'step1',
                'order' => '08'
              }
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_ssl_bump_bump_step1').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_ssl_bump_bump_step1').with_order('25-08-bump') }
        it { is_expected.to contain_concat_fragment('squid_ssl_bump_bump_step1').with_content(%r{^ssl_bump\s+bump\s+step1$}) }
      end

      context 'with one sslproxy_cert_error parameter set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            sslproxy_cert_error: {
              'myrule' => {
                'action' => 'allow',
                'value' => 'all',
                'order' => '08'
              }
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_sslproxy_cert_error_allow_all').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_sslproxy_cert_error_allow_all').with_order('35-08-allow') }
        it { is_expected.to contain_concat_fragment('squid_sslproxy_cert_error_allow_all').with_content(%r{^sslproxy_cert_error\s+allow\s+all$}) }
      end

      context 'with one icp_access parameter set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            icp_access: {
              'myrule' => {
                'action' => 'deny',
                'value' => 'this and that',
                'order' => '08'
              }
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this and that').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this and that').with_order('30-08-deny') }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this and that').with_content(%r{^icp_access\s+deny\s+this and that$}) }
      end

      context 'with two icp_access parameters set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            icp_access: {
              'myrule' => {
                'action' => 'deny',
                'value'  => 'this and that',
                'order'  => '08'
              },
              'secondrule' => {
                'action' => 'deny',
                'value'  => 'this too',
                'order'  => '09'
              }
            }

          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this and that').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this and that').with_order('30-08-deny') }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this and that').with_content(%r{^icp_access\s+deny\s+this and that$}) }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this too').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this too').with_order('30-09-deny') }
        it { is_expected.to contain_concat_fragment('squid_icp_access_this too').with_content(%r{^icp_access\s+deny\s+this too$}) }
      end

      context 'with http_port parameters set' do
        let :params do
          { config: '/tmp/squid.conf',
            http_ports: { 2000 => { 'options' => 'special for 2000' } } }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_http_port_2000').with_order('30-05') }
        it { is_expected.to contain_concat_fragment('squid_http_port_2000').with_content(%r{^http_port\s+2000\s+special for 2000$}) }
      end

      context 'with https_port parameters set' do
        let :params do
          { config: '/tmp/squid.conf',
            https_ports: { 2001 => { 'options' => 'special for 2001' } } }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_https_port_2001').with_order('30-05') }
        it { is_expected.to contain_concat_fragment('squid_https_port_2001').with_content(%r{^https_port\s+2001\s+special for 2001$}) }
      end

      context 'with snmp_port parameters set' do
        let :params do
          { config: '/tmp/squid.conf',
            snmp_ports: { 2000 => { 'options'        => 'special for 2000',
                                    'process_number' => 3 } } }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_snmp_port_2000').with_content(%r{^snmp_port\s+2000\s+special for 2000$}) }
        it { is_expected.to contain_concat_fragment('squid_snmp_port_2000').with_content(%r{^if \${process_number} = 3$}) }
        it { is_expected.to contain_concat_fragment('squid_snmp_port_2000').with_content(%r{^endif$}) }
      end

      context 'with cache_dir parameters set' do
        let :params do
          { config: '/tmp/squid.conf',
            cache_dirs: { '/data' => { 'type'    => 'special',
                                       'options' => 'my options for special type' } } }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_file('/data').with_ensure('directory') }
      end

      context 'with extra_config_sections parameter set' do
        let :params do
          {
            config: '/tmp/squid.conf',
            extra_config_sections: {
              'mail settings' => {
                'order' => '22',
                'config_entries' => {
                  'mail_from'    => 'squid@example.com',
                  'mail_program' => 'mail'
                }
              },
              'other settings' => {
                'order' => '42',
                'config_entries' => {
                  'dns_timeout' => '5 seconds'
                }
              }
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_header').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_squid__extra_config_section('mail settings') }
        it { is_expected.to contain_squid__extra_config_section('other settings') }
        it { is_expected.to contain_concat_fragment('squid_extra_config_section_mail settings').with_content(%r{^mail_from\s+squid@example\.com$}) }
        it { is_expected.to contain_concat_fragment('squid_extra_config_section_mail settings').with_content(%r{^mail_program\s+mail$}) }
        it { is_expected.to contain_concat_fragment('squid_extra_config_section_other settings').with_content(%r{^dns_timeout\s+5 seconds$}) }
      end
    end
  end
end
