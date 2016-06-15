#include <RcppArmadillo.h>
using namespace Rcpp ;
//
#include <jmotif.h>
#include <math.h>
// #include <iomanip>
// #include <iostream>
//
//' Computes a Piecewise Aggregate Approximation (PAA) for a time series.
//'
//' @param ts a timeseries to compute the PAA for.
//' @param paa_num the desired PAA size.
//' @useDynLib jmotif
//' @export
//' @references Keogh, E., Chakrabarti, K., Pazzani, M., Mehrotra, S.,
//' Dimensionality reduction for fast similarity search in large time series databases.
//' Knowledge and information Systems, 3(3), 263-286. (2001)
//' @examples
//' x = c(-1, -2, -1, 0, 2, 1, 1, 0)
//' plot(x, type = "l", main = "8-points time series and it PAA transform into three points")
//' points(x,pch = 16, lwd = 5)
//' # segments
//' abline(v = c(1, 1+7/3, 1+7/3 * 2, 8), lty = 3, lwd = 2)
// [[Rcpp::export]]
NumericVector paa(NumericVector ts, int paa_num) {
  return wrap(_paa2(Rcpp::as< std::vector<double> >(ts), paa_num));
}

std::vector<double> _paa(std::vector<double> ts, int paa_num) {

  // fix the length
  int len = ts.size();

  // check for the trivial case
  if (len == paa_num) {
    std::vector<double> res(ts);
    return res;
  }
  else {
    // if the number of points in a segment is even
    if (len % paa_num == 0) {
      std::vector<double> res(paa_num, 0);
      int inc = len / paa_num;
      for (int i = 0; i < len; i++) {
        int idx = i / inc; // the spot
        res[idx] = res[idx] + ts[i];
      }
      double dl = (double) inc;
      for (int i = 0; i < paa_num; i++) {
        res[i] = res[i] / dl;
      }
      return res;
    }else{
      // if the number of points in a segment is odd
      std::vector<double> res(paa_num);
      for (int i = 0; i < len * paa_num; i++) {
        int idx = i / len; // the spot
        int pos = i / paa_num; // the col spot
        res[idx] = res[idx] + ts[pos];
      }
      double dl = (double) len;
      for (int i = 0; i < paa_num; i++) {
        res[i] = res[i] / dl;
      }
      return res;
    }
  }
}

std::vector<double> _paa2(std::vector<double> ts, int paa_num) {

  // fix the length
  int len = ts.size();
  // Rcout << "len " << len << std::endl;

  if(len < paa_num){
    stop("'paa_num' size is invalid");
  }

  // check for the trivial case
  if (len == paa_num) {
    std::vector<double> res(ts);
    return res;
  }
  else {

    // Rcpp::Rcout.precision(5);
    // Rcout << std::fixed;

    std::vector<double> res(paa_num, 0.0);
    double points_per_segment = (double) len / (double) paa_num;
    // Rcout << "points per seg " << points_per_segment << std::endl;

    std::vector<double> breaks(paa_num + 1, 0);
    for(int i = 0; i < paa_num + 1; i++){
      breaks[i] = i * points_per_segment;
    }
    // Rcout << "breaks ";
    // for(auto it=breaks.begin(); it<breaks.end(); ++it){
      // Rcout << *it << ", ";
    // }
    // Rcout << std::endl;

    for(int i = 0; i< paa_num; i++){

      double seg_start = breaks[i];
      double seg_end = breaks[i+1];
      // Rcout << " * seg_start " << seg_start << ", end " << seg_end << std::endl;

      double frac_begin = ceil(seg_start) - seg_start;
      double frac_end = seg_end - floor(seg_end);
      // Rcout << " ** frac_begin " << frac_begin << ", frac_end " << frac_end << std::endl;

      int full_begin = floor(seg_start);
      int full_end = ceil(seg_end);
      // Rcout << " *** full_begin " << full_begin << ", full_end " << full_end << std::endl;

      std::vector<double>::const_iterator first = ts.begin() + full_begin;
      std::vector<double>::const_iterator last = ts.begin() +  full_end;
      std::vector<double> segment(first, last);

      // Rcout << "segment ";
      // for(auto it=segment.begin(); it<segment.end(); ++it){
        // Rcout << *it << ", ";
      // }
      // Rcout << std::endl;

      if(frac_begin > 0){
        segment[0] = segment[0] * frac_begin;
      }

      if(frac_end > 0){
        segment[segment.size()-1] = segment[segment.size()-1] * frac_end;
      }
      // Rcout << "adj_segment ";
      // for(auto it=segment.begin(); it<segment.end(); ++it){
        // Rcout << *it << ", ";
      // }
      // Rcout << std::endl;

      double sum_of_elems = 0.0;
      for (double n : segment)
        sum_of_elems += n;
      // Rcout << " **** sum " << sum_of_elems << std::endl;

      res[i] = sum_of_elems / points_per_segment;
      // Rcout << " **** res[" << i << "] " << res[i] << std::endl;

    }
    return res;
  }
}
