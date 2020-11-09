module.exports = {
    devServer: {
        host: 'localhost',
        hot: true,
        disableHostCheck: true,
        https: false
      },
      pages: {
        index: {
          entry: 'src/main.js',
          title: 'Pickr | Anonymous Poll App'
        }
      }
}