cask 'libreoffice43-mf' do
  version '4.3.7.2'
  sha256 'ad8cb940218ac52e240a7e26e6b079da31eb6f6205da732802b445d474353e8f'

  url "https://downloadarchive.documentfoundation.org/libreoffice/old/#{version}/mac/x86_64/LibreOffice_#{version}_MacOS_x86-64.dmg"
  name 'LibreOffice'
  homepage 'https://www.libreoffice.org/'
  license :mpl

  app 'LibreOffice.app'

  binary 'soffice'

  preflight do
    bin_launcher = "#{staged_path}/soffice"

    File.open(bin_launcher, 'w') do |f|
      f.puts('#!/bin/bash')
      f.puts('# Simply making a symlink to soffice doesn\'t seem to be enough')
      f.puts('# It may be using paths relative to itself')
      f.puts("#{staged_path}/LibreOffice.app/Contents/MacOS/soffice \"$@\"")
    end

    File.chmod(0555, bin_launcher)

  end

  zap delete: [
                '~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/org.libreoffice.script.sfl',
                '~/Library/Application Support/LibreOffice',
              ]
end
