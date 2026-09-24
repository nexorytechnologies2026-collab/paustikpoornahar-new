@extends('layouts.landing.app')
@section('title', translate('delete_account'))

@section('content')
    @php($support_email = \App\CentralLogics\Helpers::get_business_settings('email_address'))
    @php($support_phone = \App\CentralLogics\Helpers::get_business_settings('phone'))

        <!-- Page Header Gap -->
        <div class="h-148px"></div>
        <!-- Page Header Gap -->

        <section class="privacy-section">
            <div class="container">
                <div class="section-wrapper">
                    <div class="section-wrapper-inner">
                        <div class="section-header mw-100">
                            <h2 class="title"> <span class="text-base">{{ translate('delete_account') }}</span></h2>
                        </div>
                        <div class="about--content">
                            <p>{{ translate('delete_account_intro') }}</p>

                            <h4>{{ translate('delete_account_from_app') }}</h4>
                            <ol>
                                <li>{{ translate('delete_account_step_1') }}</li>
                                <li>{{ translate('delete_account_step_2') }}</li>
                                <li>{{ translate('delete_account_step_3') }}</li>
                            </ol>
                            <p>{{ translate('delete_account_running_order_note') }}</p>

                            <h4>{{ translate('delete_account_ask_us') }}</h4>
                            <p>
                                {{ translate('delete_account_ask_us_text') }}
                                @if($support_email)
                                    <br>{{ translate('Email') }}: <a href="mailto:{{ $support_email }}">{{ $support_email }}</a>
                                @endif
                                @if($support_phone)
                                    <br>{{ translate('Phone') }}: <a href="tel:{{ $support_phone }}">{{ $support_phone }}</a>
                                @endif
                            </p>

                            <h4>{{ translate('delete_account_what_is_deleted') }}</h4>
                            <p>{{ translate('delete_account_what_is_deleted_text') }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>
@endsection
