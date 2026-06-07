#import "../utils.typ": *

= Discussion <discussion>
@figsbmviwsample shows one test case as predicted by a model trained with $"W"_"v_iw"$. While the predictions are clustered more closely around the label instance, showing some learned behaviour, the clear overprediction shows that the model failed to learn relevant information about this dataset. 

#figure(
  image("../figures/results/mets/qualitative_viw/sbmsampleviw.png", width: 100%),

  caption: [Slices of a prediction output of a model trained with $"W"_"v_iw"$ on a test image of the brain metastases dataset. An annotated metastasis is shown in white with prediction shown in red.
  ],
) <figsbmviwsample>