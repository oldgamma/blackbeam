Name:		meaningfulmoon
Version:	VERSION
Release:	RELEASE
Summary:	Packages the meaningfulmoon cloud9 service

License:	GNU GPL3
URL:		https://github.com/persistentdog/meaningfulmoon
Source0:	%{name}-%{version}.tar.gz
Requires:	wildfish
Requires:	systemd

%description

%prep
%setup -q
%global debug_package %{nil}

%build

%install
rm -rf ${RPM_BUILD_ROOT} &&
mkdir --parents ${RPM_BUILD_ROOT}/usr/lib/systemd/service &&
cp meaningfulmoon.service ${RPM_BUILD_ROOT}/usr/lib/systemd/service &&
true

%files
/usr/lib/systemd/service
