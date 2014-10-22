require 'formula'
require 'pp'

class Ossim < Formula
  homepage 'http://www.ossim.org/'
  url "http://download.osgeo.org/ossim/source/ossim-1.8.18/ossim-1.8.18-1.tar.gz"
  sha1 "71881399cd999774c6daa926eee10c2e544aad3b"
  revision 1

  option 'enable-gdal', 'Build with the gdal plugin.'
  option 'enable-predator', 'Build with the preditor plugin.'
  option 'enable-las', 'Build with the las plugins'

  depends_on "cmake" => :build
  depends_on 'fftw'
  depends_on 'geos'
  depends_on 'open-scene-graph'
  depends_on 'jpeg'
  depends_on 'libtiff'
  depends_on 'libgeotiff'
  depends_on 'freetype'
  depends_on 'zlib'

  depends_on 'ffmpeg' if build.include? 'enable-predator'

  depends_on 'liblas17' if build.include? 'enable-las'

  if build.include? 'enable-gdal'
    depends_on 'gdal-110'
    depends_on 'sqlite'
    depends_on 'proj'
  end

  def get_configure_args
    args = [
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_OSX_ARCHITECTURES=\"x86_64\"",
      "-DCMAKE_INSTALL_PREFIX=#{prefix}",
      "-DBUILD_OSSIM_FRAMEWORKS=ON",
      "-DBUILD_SHARED_LIBS=ON",
      "-DBUILD_OSSIM_PACKAGES=ON",
      "-DOSSIM_BUILD_DOXYGEN=OFF",
      "-DBUILD_OSSIM_TEST_APPS=ON",
    ]

    args += [
      "-DBUILD_OSSIM_PLUGIN=ON",
      "-DBUILD_OSSIMCSM_PLUGIN=ON",
      "-DBUILD_OSSIMPNG_PLUGIN=ON",
      "-DBUILD_OSSIMREGISTRATION_PLUGIN=ON",
    ]

    args += [
      "-DBUILD_OSSIMKAKADU_PLUGIN=OFF",
      "-DBUILD_OSSIMOPENJPEG_PLUGIN=OFF",
    ]

    args += [
      "-DBUILD_OSSIMPLANET=OFF",
      "-DBUILD_OSSIMQT4=OFF",
      "-DBUILD_OSSIMGUI=OFF",
    ]

    args << "-DBUILD_OSSIMLAS_PLUGIN=" + (build.include?("enable-las") ? "ON" : "OFF")
    args << "-DBUILD_OSSIMLIBLAS_PLUGIN=" + (build.include?("enable-las") ? "ON" : "OFF")

    args << "-DBUILD_OSSIMGDAL_PLUGIN=" + (build.include?("enable-gdal") ? "ON" : "OFF")
    args << "-DBUILD_OSSIMPREDATOR_PLUGIN=" + (build.include?("enable-predator") ? "ON" : "OFF")

    return args
  end

  def install
    Dir.mkdir("ossim_package_support/cmake/build")
    ossim_dev_home = Dir.pwd

    Dir.chdir("ossim_package_support/cmake/build") do
      ENV["OSSIM_DEV_HOME"] = ossim_dev_home
      system "cmake", "..", "-G", "Unix Makefiles", *get_configure_args
      system "make"
      system "make install"
    end

    Dir.mkdir("#{prefix}/etc");
    generate_prefs("#{ossim_dev_home}/ossim/etc/templates/ossim_preferences_template","#{prefix}/etc/ossim_preferences")
  end

  def generate_prefs(template, destination)
    templatedata = File.read(template)

    # use all of the built plugins, by directory
    templatedata = templatedata.gsub(/((\/\/---[^\n]*\n)(\/\/ OSSIM plugin support:\n)(\/\/[^\n]*\n)*(\/\/---[^\n]*\n))/m, "\\1\nplugin.dir0: $(OSSIM_INSTALL_PREFIX)/lib64/ossim/plugins/\n\n")
    templatedata = templatedata.gsub(/^(plugin.file)/, '// \1')

    File.open(destination, "w") do |w|
      w.write(templatedata)
    end
  end

  def caveats;
    pg = Formula["ossim"].opt_prefix
    <<-EOS.undent
      OSSIM is now installed to #{pg}

      An example preferences file was made available at
      #{pg}/etc/ossim_preferences, edit it to point to
      local DEM data.

      To use, add the following lines to your .bashrc or similar:

      export OSSIM_PREFS_FILE=#{pg}/etc/ossim_preferences
      export OSSIM_INSTALL_HOME=#{pg}

      And call with $OSSIM_INSTALL_HOME/bin/...

      Update the preference file to use local data sources.
      EOS
  end

end
