@extends('layouts.installer')

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="card mt-3">
                <div class="card-body">
                    <div class="mar-ver pad-btm text-center mb-4">
                        <h1 class="h3">
                            Software Update
                        </h1>
                    </div>


                    <form method="POST" action="{{route('update-system')}}">
                        @csrf
                        <div class="bg-light p-4 rounded mb-4">
                            <div class="px-xl-2 pb-sm-3">
                                <div class="d-flex gap-3 align-items-center">
                                    <img
                                        src="{{dynamicAsset('assets/installation')}}/assets/img/svg-icons/php-version.svg"
                                        alt="">
                                    <div
                                        class="d-flex align-items-center gap-2 justify-content-between flex-grow-1">
                                        PHP Version 8.2 +

                                        @php($phpVersion = number_format((float)phpversion(), 2, '.', ''))
                                        @if ($phpVersion >= 8.2)
                                            <img width="20"
                                                 src="{{dynamicAsset('assets/installation')}}/assets/img/svg-icons/check.png"
                                                 alt="">
                                        @else
                                            <span class="cursor-pointer" data-bs-toggle="tooltip"
                                                  data-bs-placement="top" data-bs-custom-class="custom-tooltip"
                                                  data-bs-html="true" data-bs-delay='{"hide":1000}'
                                                  data-bs-title="Your php version in server is lower than 8.2 version
                                                       <a href='https://support.cpanel.net/hc/en-us/articles/360052624713-How-to-change-the-PHP-version-for-a-domain-in-cPanel-or-WHM'
                                                       class='d-block' target='_blank'>See how to update</a> ">
                                                    <img
                                                        src="{{dynamicAsset('assets/installation')}}/assets/img/svg-icons/info.svg"
                                                        class="svg text-danger" alt="">
                                                </span>
                                        @endif

                                    </div>
                                </div>


                            </div>
                        </div>

                        <div class="text-center">
                            <button type="submit" class="btn btn-dark px-sm-5" {{ $phpVersion >= 8.2?'':'disabled' }} >Update</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endsection
