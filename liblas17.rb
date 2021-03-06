require 'formula'

class Liblas17 < Formula
  homepage 'http://liblas.org'
  url 'http://download.osgeo.org/liblas/libLAS-1.7.0.tar.gz'
  sha256 'e6b30c4530fef283e680fac59b199e1be6b96994fb663d08fd12838eef928277'

  head 'https://github.com/libLAS/libLAS.git'

  depends_on 'cmake' => :build
  depends_on 'libgeotiff'
  depends_on 'gdal'
  depends_on 'boost'
  depends_on 'laszip' => :optional

  option 'with-test', 'Verify during install with `make test`'

  # Fix for error of conflicting types for '_GTIFcalloc' between gdal 1.11
  # and libgeotiff. Commited so can be removed on next stable release.
  # https://github.com/libLAS/libLAS/issues/33
  patch do
    url "https://github.com/libLAS/libLAS/commit/b8799e.diff"
    sha256 "d07848568be08e72b50008a45506b4db34640b629d72ff9931e55bd04af21a64"
  end

  def install
    mkdir 'macbuild' do
      # CMake finds boost, but variables like this were set in the last
      # version of this formula. Now using the variables listed here:
      #   http://liblas.org/compilation.html
      ENV['Boost_INCLUDE_DIR'] = "#{HOMEBREW_PREFIX}/include"
      ENV['Boost_LIBRARY_DIRS'] = "#{HOMEBREW_PREFIX}/lib"
      args = ["-DWITH_GEOTIFF=ON", "-DWITH_GDAL=ON"] + std_cmake_args
      args << "-DWITH_LASZIP=ON" if build.with? 'laszip'
      system "cmake", "..", *args
      system "make"
      system "make test" if build.with? "test"
      system "make install"
    end
  end

  test do
    system bin/"liblas-config", "--version"
  end
end
