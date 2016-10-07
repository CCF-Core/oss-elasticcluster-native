const Promise = require('bluebird');
const _ = require('lodash');

const pdf = require('./pdf');
const oncePerServer = require('./once_per_server');
const getScreenshotFactory = require('./get_screenshot');

function generateDocumentFactory(server) {
  const getScreenshot = getScreenshotFactory(server);

  return {
    printablePdf: printablePdf,
  };

  function printablePdf(savedObjects, query, headers) {
    const pdfOutput = pdf.create();

    return Promise.map(savedObjects, function (savedObj) {
      if (savedObj.isMissing) {
        return savedObj;
      } else {
        return getScreenshot(savedObj.url, savedObj.type, headers)
        .then((filename) => {
          server.log(['reporting', 'debug'], `${savedObj.id} -> ${filename}`);
          return _.assign({ filename }, savedObj);
        });
      }
    })
    .then(objects => {
      objects.forEach(object => {
        if (object.isMissing) {
          pdfOutput.addHeading(`${_.capitalize(object.type)} with id '${object.id}' not found`, {
            styles: 'warning'
          });
        } else {
          pdfOutput.addImage(object.filename, {
            title: object.title,
            description: object.description,
          });
        }
      });
    })
    .then(function () {
      return pdfOutput.generate();
    });
  };
}

module.exports = oncePerServer(generateDocumentFactory);
